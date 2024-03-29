#!/usr/bin/perl

# Variables generales
$debug = 0;						# Debuggeando? 0=no, 1=si
$write = 0;						# Va a escribir en archivo? 0=no, 1=si

if ($debug == 1)
{
	$MAEDIR = ".";
	$PROCDIR = ".";
	$REPODIR = ".";
}

# Archivo que se usa para no permitir mas de una instancia en ejecucion del programa
$fnamepid="/tmp/Imprimir_A.PID";

# Archivos de input
$in_salas = "$ENV{'GRUPO'}/$ENV{'MAEDIR'}/"."salas.mae";	#id (n° par);nombre;capacidad;direccion;telefono;email
$in_obras = "$ENV{'GRUPO'}/$ENV{'MAEDIR'}/"."obras.mae";	#id (n° impar);nombre;email produccion general;email produccion ejecutiva
$in_reservas_confirmadas = "$ENV{'GRUPO'}/$ENV{'PROCDIR'}/"."reservas.ok";	#id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo[;ref int];cant butacas solicitadas;email;usuario;fecha grabacion
$in_reservas_no_confirmadas = "$ENV{'GRUPO'}/$ENV{'PROCDIR'}/"."reservas.nok";   #ref int;fecha;hora;numero fila;numero butaca;cant butacas solicitadas;seccion;motivo;id sala;id obra;email;usuario;fecha grabacion
$in_disponibilidad = "$ENV{'GRUPO'}/$ENV{'PROCDIR'}/"."combos.dis"; #id combo;id obra;fecha;hora;id sala;butacas habilitadas;butacas disp;requisitos especiales

sub end {
    unlink $fpid;	#Borro el archivo
}

# ---------- INICIO COMPROBACIONES DE RUTINA ------------
if ($INICIAR_A_EJECUTADO_EXITOSAMENTE == 1)
{
	print "ERROR: el ambiente no fue inicializado. \n";
	exit(1);
}

if (-e "$fnamepid") 
{
	open ($fpid, "<$fnamepid");
	$pid_existente=<$fpid>;
	$cantidad=`ps ax | grep -c "^ $pid_existente"`;
	close ($fpid);
	if ($cantidad >= 1)
	{
		print "ERROR: hay otra instancia del script en ejecución. \n";
		exit(1);
	}
}

open ($fpid, ">$fnamepid");
print $fpid $$;		# Escribo el pid del proceso en el archivo
close ($fpid);

# ---------- FIN COMPROBACIONES DE RUTINA ------------

# ---------- INICIO PROCESAMIENTO ARGUMENTOS ------------
%opciones = ("-i" => \&fInvitados, "-d" => \&fDisp, "-r" => \&fRanking, "-t" => \&fTickets);

$num_argv = $#ARGV +1;

if ($num_argv == 0) {
	print "ERROR: faltan parámetros.\n";
	&uso;&end;exit(1);
}
if (($num_argv > 2) || ($ARGV[0] eq "-a")) {
	&uso;&end;exit(1);
}
elsif (($num_argv == 2) && ($ARGV[0] eq "-w")) 
{
	$write = 1;
	if ( exists($opciones{$ARGV[1]}) )	#Si existe la opcion
	{
		&{$opciones{$ARGV[1]}};		#Llamo a la funcion correspondiente
		&end;exit(0);
	}
}
elsif (($num_argv == 1) && (exists($opciones{$ARGV[0]}))) 
{
	&{$opciones{$ARGV[0]}};
	&end;exit(0);
}
else {
	print "ERROR: parámetros incorrectos.\n";
	&uso;&end;exit(1);
}

# ---------- FIN PROCESAMIENTO ARGUMENTOS ------------

sub uso {
	print "Uso: $0 [-w] -<i|d|r|t>"."\n";
	print "\t [-w]: Graba en el archivo correspondiente."."\n";
	print "\t -i: Genera lista de invitados para las reservas confirmadas."."\n";
	print "\t -d: Realiza consultas de disponibilidad."."\n";
	print "\t -r: Emite el ranking de los 10 eventos con más reservas confirmadas."."\n";
	print "\t -t: Genera archivos para imprimir los tickets de entrada."."\n";
}

sub existeIDobra {
	local $id_obra = $_[0];
	# Se retorna el siguiente valor (cuantas lineas tienen el ID de obra)
	$lineas = `grep -c "^$id_obra;" "$in_obras"`;
}

sub existeIDsala {
	local $id_sala = $_[0];
	# Se retorna el siguiente valor (cuantas lineas tienen el ID de sala)
	$lineas = `grep -c "^$id_sala;" "$in_salas"`;
}

sub existeIDcombo {
	local $consulta = $_[0];
	local @combos_unicos = @_;		# El primer valor (0) será la consulta.
	local $resultado = 0;
	for ($i = 1; $i < $#combos_unicos + 1; $i++)
	{
		if ("$combos_unicos[$i]" eq $consulta) {
			$resultado = 1;
		}
	}
	return $resultado;
}

sub generar_listado_eventos_candidatos {
	%eventos_candidatos = ();		#id evento => datos evento
	%referencias_internas = ();		#referencia interna => id evento
	
	# $in_reservas_confirmadas = "$ENV{'GRUPO'}/$ENV{'PROCDIR'}/"."reservas.ok";	
	#	id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo[;ref int];cant butacas solicitadas;email;usuario;fecha grabacion
	open($reservas, '<', $in_reservas_confirmadas);
	while ($linea = <$reservas>) 
	{
		chomp($linea);
		#Datos del evento
		@de = split(";", $linea);		
		$id_evento = $de[7];
		$ref_int = $de[8];
		if ($ref_int ne "") #Hay ref interna del solicitante?
		{
			$datos_evento = "Evento: $de[7] Obra: $de[0]-$de[1] Fecha y Hora: $de[2]-$de[3] Sala: $de[4]-$de[5]"."\n";
			$eventos_candidatos{$id_evento} = $datos_evento;
			$referencias_internas{$ref_int} = $id_evento;
		}
	}
	close ($reservas);
}

sub sumar_reservas_confirmadas {
	local $ref_int = $_[0];
	local $suma = 0;
	$res = `grep ";$ref_int;" $in_reservas_confirmadas | cut -d ";" -f 7`;
	@valores = split ("\n", $res);
	for ($i = 0; $i < $#valores + 1; $i++)
	{
		$suma += $valores[$i];
	}
	return ($suma);
}

sub es_rango_valido {
	local $min = $_[0];
	local $max = $_[1];
	if ($min < $max) {$result = 1;}	# 1=rango válido
	else {$result = 0;}				# 0=rango inválido
	return ($result);
}

sub esDigito {
	$res = 1; # 0 es true, 1 es false
	if ($_[0] =~ /(\d)*/){
		$res = 0;
	}
	return ($res);
}

sub mostrar_ids_obras {
	open ($fh, "<$in_obras");
	print "Listado de IDs de obras: \n";
	while ($linea = <$fh>)
	{
		chomp($linea);
		@campos = split (";", $linea);
		$id_obra = $campos[0];
		print $id_obra." ";
	}
	print "\n";
	close($fh);	
}

sub mostrar_ids_salas {
	open ($fh, "<$in_salas");
	print "Listado de IDs de salas: \n";
	while ($linea = <$fh>)
	{
		chomp($linea);
		@campos = split (";", $linea);
		$id_sala = $campos[0];
		print $id_sala." ";
	}
	print "\n";
	close($fh);
}

sub remover_duplicados_de_array {
	my @array  = $_[0];
	my %hash   = map { $_ => 1 } @array;
	my @unique = keys %hash;
	
	for ($x = 0; $x < $#unique; $x ++)
	{
		print "$unique[$x] ";
	}
	
	return (@unique);
}

sub mostrar_ids_combos {
	local @id_combos;
	open ($fh, "<$in_reservas_confirmadas");
	
	while ($linea = <$fh>)
	{
		chomp($linea);
		@campos = split (";", $linea);
		$id_combo = $campos[7];
		push(@id_combos,$id_combo);
	}
	
	%hash_id_combos_unicos   = map { $_ => 1 } @id_combos;
	@id_combos_unicos = keys %hash_id_combos_unicos;
	
	print "Listado de IDs de combos que poseen reservas: \n";
	for ($x = 0; $x < $#id_combos_unicos +1; $x ++)
	{
		print "$id_combos_unicos[$x] ";
	}
	print "\n";
	close($fh);
	
}

sub generar_disponibilidad_por_obra {
	local $id_obra = $_[0];
	
	$resultados = `sed "s/;/-/g" $in_disponibilidad`;		#Reemplazo ; por -
		
	$resultados = `echo -n "$resultados" | grep "^[^-]*-$id_obra-.*"`;	#Selecciono por id de obra (2do campo)	
	
	$resultados = `echo -n "$resultados" | cut -d "-" -f 1-7`;	#Quito el ultimo campo
	
	$resultados = `echo -n "$resultados" | sed "s/-/\t/g"`;	#Reemplazo "-" por "\t"
	
	print "$resultados";
	&escribir_listado_disponibilidad($nombre_listado);
	return ($resultados);
}

sub escribir_titulo_D {
	$titulo1 = "ID Combo\tID Obra\tFecha\t\tHora\tID sala\tBut Hab\tBut Disp \n";
	print "$titulo1";
	$titulo2 = "--------\t-------\t-----\t\t----\t-------\t-------\t-------- \n";
	print "$titulo2";
	
	local $out_disponibilidad = "$ENV{'GRUPO'}/$ENV{'REPODIR'}"."/"."$_[0]".".dis";
	if ($write == 1)
	{
		open ($fh, ">>$out_disponibilidad");		#Modo overwrite
		print $fh "$titulo1";					#Escribo en el archivo
		print $fh "$titulo2";					#Escribo en el archivo
		close ($fh);
	}
}

sub generar_disponibilidad_por_rango_obra {
	local $min = $_[0];
	local $max = $_[1];
	
	for ($i=$min; $i <= $max; $i++)
	{
		&generar_disponibilidad_por_obra($i);
	}
}

sub generar_disponibilidad_por_sala {
	local $id_sala = $_[0];

	$resultados = `sed "s/;/-/g" $in_disponibilidad`;		#Reemplazo ; por -
	
	$resultados = `echo -n "$resultados" | grep "^[^-]*-[^-]*-[^-]*-[^-]*-$id_sala-"`;	#Selecciono por id de sala (5to campo)

	$resultados = `echo -n "$resultados" | cut -d "-" -f 1-7`;	#Quito el ultimo campo
	
	$resultados = `echo -n "$resultados" | sed "s/-/\t/g"`;	#Reemplazo "-" por "\t"
	
	print "$resultados";
	&escribir_listado_disponibilidad($nombre_listado);
	return ($resultados);
}

sub generar_disponibilidad_por_rango_sala {
	local $min = $_[0];
	local $max = $_[1];
	
	for ($i=$min; $i <= $max; $i++)
	{
		&generar_disponibilidad_por_sala($i);
	}
}

sub escribir_listado_disponibilidad {
	local $out_disponibilidad = "$ENV{'GRUPO'}/$ENV{'REPODIR'}"."/"."$_[0]".".dis";
	if ($write == 1)
	{
		open ($fh, ">>$out_disponibilidad");		#Modo append
		print $fh "$resultados";					#Escribo en el archivo
		close ($fh);
	}
}

sub escribir_listado_invitados {
	local $out_invitados_confirmados = "$ENV{'GRUPO'}/$ENV{'REPODIR'}"."/"."$evento".".inv";
	local $archivo;
	
	# Escribo el listado en la consola
	foreach $linea (@_) {
		print "$linea";		
	}
	
	# Escribo el listado en el archivo de invitados
	if ($write == 1) 
	{
		open ($archivo, '>', $out_invitados_confirmados);		
		foreach $linea (@_) {
			print $archivo "$linea";		
		}
		close ($archivo);	
	}
}

#Parametro 0: id_combo
#Parametro 1: array de tickets
sub escribir_listado_tickets {
	local $out_tickets = "$ENV{'GRUPO'}/$ENV{'REPODIR'}"."/"."$_[0]".".tck";
	open (MYFILE, ">$out_tickets");				#Modo overwrite
	
	local $tickets = $_[1];
	local $cant_tickets = $#tickets + 1;
	for ($i = 0; $i < $cant_tickets; $i ++) {
		print MYFILE "$tickets[$i]";					#Escribo en el archivo
	}
	close (MYFILE);
	
}

sub generar_nnn {
	# Extension autoincremental del archivo
	$nnn=`ls "$ENV{'GRUPO'}/$ENV{'REPODIR'}" | grep "^ranking" | sed s/ranking\.//g | sort -r | head -n 1`;

    # En caso de no existir un archivo "ranking.*" inicializo nnn en 0
	if ($nnn eq "") {
	    $nnn=0;
	}
	
	$nnn += 1;
}

sub escribir_listado_ranking {
	local $nnn = $_[0];
	local $linea = $_[1];
	
	$out_ranking = "$ENV{'GRUPO'}/$ENV{'REPODIR'}"."/ranking."."$nnn";
	if ($write == 1)
	{
		open (MYFILE, ">>$out_ranking");	#Modo append
		print MYFILE "$linea";				#Escribo en el archivo
		close (MYFILE);
	}
}

sub fInvitados {
	# Archivo necesario: in_reservas_confirmadas
	if (! -e $in_reservas_confirmadas)
	{
		print "ERROR: no se encontró el archivo $in_reservas_confirmadas.\n";
		exit(1);
	}
	&generar_listado_eventos_candidatos;
	
	foreach $key (keys(%eventos_candidatos)) {
		print $eventos_candidatos{$key};		
	}

	pideEventoCandidato: print "Ingrese un evento candidato: ";
	local $evento = <STDIN>; chomp($evento);
	while (exists($eventos_candidatos{$evento}) == 0) {
		print "ERROR: Evento inválido.\n";
		goto pideEventoCandidato;
	}
	
	print "Evento válido.\n";
	
	local @out = ();
	
	push(@out,$eventos_candidatos{$evento});
	
	local $total_acumulado = 0;
	foreach $ref_int (keys(%referencias_internas))
	{
		if ($referencias_internas{$ref_int} eq $evento)
		{
			$total_acumulado_ref_int = 0;
			push(@out,"Referencia interna: $ref_int \n");
			
			local $nom_archivo_invitados = "$ENV{'GRUPO'}/$ENV{'REPODIR'}/"."$ref_int".".inv";
			
			# No existe archivo de invitados
			if (! -e $nom_archivo_invitados) 
			{
				push (@out, "\t Sin listado de invitados.\n");
			}
			
			else {
				open ($arch_invitados, '<', $nom_archivo_invitados) or die "No se pudo abrir '$nom_archivo_invitados' $!\n";;
								
				while ($linea = <$arch_invitados>) 
				{
					chomp($linea);
					$linea =~ s/\r//g;
					@campos = split (";" , $linea); # 0-> invitado (ob), 1 -> empresa (opc), 2-> cantidad acompañantes (opc)
					local $cant_acomp = 0;
					if (($#campos + 1 == 3))
					{
						$cant_acomp = $campos[2];
						
					}
					elsif (($#campos + 1 == 2) && (&esDigito($campos[1]) == 0))
					{
						$cant_acomp = $campos[1];
					}
					$total_acumulado_ref_int += 1 + $cant_acomp;
					
					$linea = "\t $campos[0]".", "."$cant_acomp".", "."$total_acumulado_ref_int"."\n";
					push(@out, "$linea");
				}
				close ($arch_invitados);				
			}
			$cant_reservas_confirmadas = &sumar_reservas_confirmadas($ref_int);
			$total_acumulado += $cant_reservas_confirmadas;
			push(@out,"\t \t Total reservas confirmadas: $cant_reservas_confirmadas \n");
			push(@out,"\t \t \t \t \t \t Total acumulado: $total_acumulado \n");
		}		
	}
	
	&escribir_listado_invitados(@out);
}

sub fDisp {
	# Archivos necesarios: in_salas, in_obras, in_disponibilidad
	if ((! -e $in_salas) || (! -e $in_obras) || (! -e $in_disponibilidad))
	{
		print "ERROR: falta alguno de los siguientes archivos: ";
		print "$in_salas, $in_obras, $in_disponibilidad.\n";
		exit(1);
	}
	
	&mostrar_ids_obras;
	&mostrar_ids_salas;
	local %opciones_fdisp = (1, "ID OBRA", 2, "ID SALA", 3, "RANGO de ID OBRA", 4, "RANGO de ID SALA");
	local $opcion_elegida = "";
	
	# Paso 1: si es necesario, pedir el nombre del listado a generar.
	if ($write == 1)
	{
		$nombre_listado = "";
		while (($nombre_listado eq "") || ($nombre_listado eq "combos"))
		{
			print "Indicó que quiere grabar los resultados. Ingrese el nombre para el listado: ";
			$nombre_listado = <STDIN>;
			chomp($nombre_listado);
		}
	}

	print "Generar disponibilidad por... \n";
	# Paso 2: Pedir un dato inicial
	while (exists($opciones_fdisp{$opcion_elegida}) == 0)
	{
		for ($op = 1; $op < 5; $op++) {
			print "Opción ".$op.": ".$opciones_fdisp{$op}."\n";
		}
		print "Ingrese la opción deseada: ";
		$opcion_elegida = <STDIN>;
		chomp($opcion_elegida);
	}
	
	# Paso 3: procesar la opción
	if ($opciones_fdisp{$opcion_elegida} eq "ID OBRA")
	{
		pideIDobra:print "Ingrese un ID de obra: ";
		$id_obra = <STDIN>; chomp($id_obra);
		while(&existeIDobra($id_obra) == 0) {
			print "ERROR: No se encontró ese ID de obra.\n";
			goto pideIDobra;
		}
		
		print "ID obra encontrado. \n";
		&escribir_titulo_D($nombre_listado);
		&generar_disponibilidad_por_obra($id_obra);
	}
	elsif ($opciones_fdisp{$opcion_elegida} eq "ID SALA")
	{
		pideIDsala:print "Ingrese un ID de sala: ";
		$id_sala= <STDIN>; chomp($id_sala);
		while(&existeIDsala($id_sala) == 0) {
			print "ERROR: No se encontró ese ID de sala.\n";
			goto pideIDsala;
		}
		
		print "ID sala encontrado. \n";
		&escribir_titulo_D($nombre_listado);
		&generar_disponibilidad_por_sala($id_sala);		
	}
	elsif ($opciones_fdisp{$opcion_elegida} eq "RANGO de ID OBRA")
	{
		pideRangoIDobra: print "Ingrese el mínimo de ID de obra: ";
		$min_id_obra = <STDIN>; chomp($min_id_obra);
		print "Ingrese el máximo de ID de obra: ";
		$max_id_obra = <STDIN>; chomp($max_id_obra);
		while (&es_rango_valido($min_id_obra,$max_id_obra) == 0) {
			print "ERROR: Rango inválido.\n"; 
			goto pideRangoIDobra;
		}
		
		print "Rango ID obra válido. \n";
		&escribir_titulo_D($nombre_listado);
		&generar_disponibilidad_por_rango_obra($min_id_obra,$max_id_obra);
	}
	elsif ($opciones_fdisp{$opcion_elegida} eq "RANGO de ID SALA")
	{
		pideRangoIDsala: print "Ingrese el mínimo de ID de sala: ";
		$min_id_sala = <STDIN>; chomp($min_id_sala);
		print "Ingrese el máximo de ID de sala: ";
		$max_id_sala = <STDIN>; chomp($max_id_sala);
		while (&es_rango_valido($min_id_sala,$max_id_sala) == 0) {
			print "ERROR: Rango inválido.\n"; 
			goto pideRangoIDsala;
		}
		
		print "Rango ID sala válido. \n";
		&escribir_titulo_D($nombre_listado);
		&generar_disponibilidad_por_rango_sala($min_id_sala,$max_id_sala);
	}
	exit(0);	
}

sub fRanking {
	#$in_reservas_confirmadas = "$ENV{'GRUPO'}/$ENV{'PROCDIR'}/"."reservas.ok";	
	#id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo[;ref int];cant butacas solicitadas;email;usuario;fecha grabacion
	
	# Archivo necesario: in_reservas_confirmadas	
	if (! -e $in_reservas_confirmadas)
	{
		print "ERROR: no se encontró el archivo $in_reservas_confirmadas.\n";
		exit(1);
	}
	
	$cantidad = 10;
	# Ordeno en orden descendente (r) por el 7mo campo (n-numerico) con delimitador ";"
	# Y luego muestro solo las primeras 10 lineas
	$top10ordenado = `sort -t';' -k7nr $in_reservas_confirmadas | head -n $cantidad`;
	
	$nnn = &generar_nnn;
	
	@lineas = split("\n", $top10ordenado);	#Un array con cada linea sin cortar
	@alarchivo = ();	#Un array con cada linea cortada como se requiere
	for ($i = 0; $i < $cantidad; $i++)
	{
		@campos = split (";", $lineas[$i]);		#Separamos cada linea en sus campos
		$resultado = "NOMBRE OBRA: $campos[1], NOMBRE SALA: $campos[5], FECHA: $campos[2], OBRA: $campos[3], CANTIDAD BUTACAS CONFIRMADAS: $campos[6]";
		print "$resultado\n";
		push(@alarchivo,$resultado);
		
	}
	$resultado = join("\n", @alarchivo);	
	&escribir_listado_ranking($nnn, $resultado);
}

sub fTickets {
	
	# Archivos necesarios: in_disponibilidad, in_reservas_confirmadas	
	if ((! -e $in_disponibilidad) || (! -e $in_reservas_confirmadas))
	{
		print "ERROR: no se encontraron los archivos $in_disponibilidad y $in_reservas_confirmadas.\n";
		exit(1);
	}
	&mostrar_ids_combos;
	pideIDcombo: print "Ingrese ID del combo: ";
	$id_combo = <STDIN>; chomp($id_combo);
	
	while (&existeIDcombo($id_combo,@id_combos_unicos) == 0)
	{
		print "ERROR: ID de combo inválido.\n";
		goto pideIDcombo;
	}
	
	#$in_reservas_confirmadas = "$ENV{'GRUPO'}/$ENV{'PROCDIR'}/"."reservas.ok";	
	#id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo;ref int;cant butacas solicitadas;email;usuario;fecha grabacion
	
	#Examino el archivo de reservas linea por linea
	open($reservas, '<', $in_reservas_confirmadas);
	@tickets = ();
	while ($linea = <$reservas>) {
		chomp($linea);
		@campos = split (";" , $linea);
		if ($campos[7] eq $id_combo)
		{
			$cant_but_confir = $campos[6];
			print "Cantidad de tickets a emitir: $cant_but_confir\n";
			if ($cant_but_confir <= 2) 
			{
				$string = ''; if ($cant_but_confir == 2) {$string = 'S';}
				$un_ticket= "VALE POR $cant_but_confir ENTRADA$string; $campos[1]; $campos[2]; $campos[3]; $campos[5]; $campos[8]; $campos[10] \n";
				print "\t $un_ticket";
				push(@tickets, $un_ticket);
				
			}
			else {
				local $cant_but_confir_es_impar = $cant_but_confir % 2 == 1; # 0=no, 1=si
				
				#Emito los "vale por 2 entradas" que correspondan
				$cant_vale_por_2 = ($cant_but_confir - $cant_but_confir_es_impar)/2;
				for ($i = 0; $i < $cant_vale_por_2; $i++)
				{
					$un_ticket= "VALE POR 2 ENTRADAS; $campos[1]; $campos[2]; $campos[3]; $campos[5]; $campos[8]; $campos[10] \n";
					print "\t $un_ticket";
					push(@tickets, $un_ticket);
				}
				
				#Si la cantidad era impar, emito un unico "vale por 1 entrada"
				if ($cant_but_confir_es_impar == 1)
				{
					$un_ticket= "VALE POR 1 ENTRADA; $campos[1]; $campos[2]; $campos[3]; $campos[5]; $campos[8]; $campos[10] \n";
					print "\t $un_ticket";
					push(@tickets, $un_ticket);
				}
			}
		}
	}

	&escribir_listado_tickets($id_combo, @tickets);
	
	close ($reservas);
}
