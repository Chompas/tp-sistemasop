#!/usr/bin/perl

# Variables generales
$debug = 0;						# Debuggeando? 0=no, 1=si
$write = 0;						# Va a escribir en archivo? 0=no, 1=si

if ($debug == 0)
{
	$MAEDIR = ".";
	$PROCDIR = ".";
	$REPODIR = ".";
}

# Archivos de input
$in_salas = "$MAEDIR/"."salas.mae";	#id (n° par);nombre;capacidad;direccion;telefono;email
$in_obras = "$MAEDIR/"."obras.mae";	#id (n° impar);nombre;email produccion general;email produccion ejecutiva
$in_reservas_confirmadas = "$PROCDIR/"."reservas.ok";	#id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo[;ref int];cant butacas solicitadas;email;usuario;fecha grabacion
$in_reservas_no_confirmadas = "$PROCDIR/"."reservas.nok";   #ref int;fecha;hora;numero fila;numero butaca;cant butacas solicitadas;seccion;motivo;id sala;id obra;email;usuario;fecha grabacion
$in_disponibilidad = "$PROCDIR/"."combos.dis"; #id combo;id obra;fecha;hora;id sala;butacas habilitadas;butacas disp;requisitos especiales

sub end {
    close ($fpid);
    unlink "Imprimir_A.PID" or warn "ERROR: no se pudo borrar Imprimir_A.PID.";
}

# ---------- INICIO COMPROBACIONES DE RUTINA ------------
if ($INICIAR_A_EJECUTADO_EXITOSAMENTE == 1)
{
	print "ERROR: el ambiente no fue inicializado. \n";
	exit(1);
}

if (-e "Imprimir_A.PID") 
{
	print "ERROR: hay otra instancia del script en ejecución. \n";
	exit(1);
}

open ($fpid, '>', "Imprimir_A.PID");

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
		&end;
	}
}
elsif (($num_argv == 1) && (exists($opciones{$ARGV[0]}))) 
{
	&{$opciones{$ARGV[0]}};
	&end;
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
	local $id_combo = $_[0];
	# Se retorna el siguiente valor (cuantas lineas tienen el ID de combo)
	$lineas = `grep -c "^$id_combo;" "$in_disponibilidad"`;
}

sub generar_listado_eventos_candidatos {
	%eventos_candidatos = ();		#id evento => datos evento
	%referencias_internas = ();		#referencia interna => id evento
	
	# $in_reservas_confirmadas = "$PROCDIR/"."reservas.ok";	
	#	id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo[;ref int];cant butacas solicitadas;email;usuario;fecha grabacion
	open($reservas, '<', $in_reservas_confirmadas) or die "No se pudo abrir '$in_reservas_confirmadas' $!\n";
	while ($linea = <$reservas>) 
	{
		chomp($linea);
		#Datos del evento
		@de = split(";", $linea);
		if ($#de + 1 == 13) #Hay ref interna del solicitante?
		{
			$datos_evento = "Evento: $de[7] Obra: $de[0]-$de[1] Fecha y Hora: $de[2]-$de[3] Sala: $de[4]-$de[5]"."\n";
			$eventos_candidatos{$de[7]} = $datos_evento;
			$referencias_internas{$de[8]} = $de[7];
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

sub generar_disponibilidad_por_obra {
	local $id_obra = $_[0];
	
	$resultados = `sed "s/;/-/g" $in_disponibilidad`;		#Reemplazo ; por -
		
	$resultados = `echo -n "$resultados" | grep "^[^-]*-$id_obra-.*"`;	#Selecciono por id de obra (2do campo)	
	
	$resultados = `echo -n "$resultados" | cut -d "-" -f 1-7`;	#Quito el ultimo campo
	print "$resultados";
	&escribir_listado_disponibilidad($nombre_listado);
	return ($resultados);
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
	local $out_disponibilidad = "$REPODIR"."/"."$_[0]".".dis";
	if ($write == 1)
	{
		open (MYFILE, ">>$out_disponibilidad");		#Modo append
		print MYFILE "$resultados";					#Escribo en el archivo
		close (MYFILE);
	}
}

sub escribir_listado_invitados {
	local $out_invitados_confirmados = "$REPODIR"."/"."$evento".".inv";
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
	local $out_tickets = "$REPODIR"."/"."$_[0]".".tck";
	open (MYFILE, ">$out_tickets");				#Modo overwrite
	
	local $tickets = $_[1];
	local $cant_tickets = $#tickets + 1;
	for ($i = 0; $i < $cant_tickets; $i ++) {
		print MYFILE "$tickets[$i]";					#Escribo en el archivo
	}
	close (MYFILE);
	
}

sub escribir_ranking {
	local $linea = $_[0];
	
	# Extension autoincremental del archivo
	$nnn=`ls "$REPODIR" | grep "^ranking" | sed s/ranking\.//g | sort -r | head -n 1`;

    # En caso de no existir un archivo "ranking.*" inicializo nnn en 0
	if ($nnn eq "") {
	    $nnn=0;
	}
	
	$nnn += 1;
	if ($debug == 1) {print "nnn = $nnn\n";}
	
	$out_ranking = "$REPODIR"."/ranking."."$nnn";
	if ($write == 1)
	{
		open (MYFILE, ">>$out_ranking");	#Modo append
		print MYFILE "$linea";				#Escribo en el archivo
		close (MYFILE);
	}
}

sub fInvitados {
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
	
	foreach $ref_int (keys(%referencias_internas))
	{
		if ($referencias_internas{$ref_int} eq $evento)
		{
			local $total_acumulado = 0;
			push(@out,"$ref_int \n");
			
			local $nom_archivo_invitados = "$REPODIR/"."$ref_int".".inv";
			
			# No existe archivo de invitados
			if (! -e $nom_archivo_invitados) 
			{
				push (@out, "Sin listado de invitados.\n");
			}
			
			else {
				open ($arch_invitados, '<', $nom_archivo_invitados) or die "No se pudo abrir '$nom_archivo_invitados' $!\n";;
								
				while ($linea = <$arch_invitados>) 
				{
					chomp($linea);
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
					$total_acumulado+=1 + $cant_acomp;
					$linea = "$campos[0]".", "."$cant_acomp".", "."$total_acumulado"."\n";
					push(@out, "$linea");
				}
				close ($arch_invitados);				
			}
			push(@out,&sumar_reservas_confirmadas($ref_int)."\n");
			push(@out,"$total_acumulado \n");
		}		
	}
	
	&escribir_listado_invitados(@out);
}

sub fDisp {
	#$in_disponibilidad = "$PROCDIR"."/combos.dis"; #id combo;id obra;fecha;hora;id sala;butacas habilitadas;butacas disp;requisitos especiales
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
		&generar_disponibilidad_por_rango_sala($min_id_sala,$max_id_sala);
	}
	exit(0);	
}

sub fRanking {
	#$in_reservas_confirmadas = "$PROCDIR/"."reservas.ok";	
	#id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo[;ref int];cant butacas solicitadas;email;usuario;fecha grabacion
	$cantidad = 10;
	# Ordeno en orden descendente (r) por el 7mo campo (n-numerico) con delimitador ";"
	# Y luego muestro solo las primeras 10 lineas
	$top10ordenado = `sort -t';' -k7nr $in_reservas_confirmadas | head -n $cantidad`;
	@lineas = split("\n", $top10ordenado);	#Un array con cada linea sin cortar
	@alarchivo = ();	#Un array con cada linea cortada como se requiere
	for ($i = 0; $i < $cantidad; $i++)
	{
		@campos = split (";", $lineas[$i]);		#Separamos cada linea en sus campos
		$resultado = "$campos[1], $campos[5], $campos[2], $campos[3], $campos[6]";
		print "$resultado\n";
		push(@alarchivo,$resultado);
		
	}
	$resultado = join("\n", @alarchivo);
	&escribir_ranking($resultado);
}

sub fTickets {
	pideIDcombo: print "Ingrese ID del combo: ";
	$id_combo = <STDIN>; chomp($id_combo);
	while (&existeIDcombo($id_combo) == 0)
	{
		print "ERROR: ID de combo inválido.\n";
		goto pideIDcombo;
	}
	print "ID de combo válido.\n";
	
	#$in_reservas_confirmadas = "$PROCDIR/"."reservas.ok";	
	#id obra;nombre;fecha;hora;id sala;nombre sala;cant butacas confir;id combo;ref int;cant butacas solicitadas;email;usuario;fecha grabacion
	
	#Examino el archivo de reservas linea por linea
	open($reservas, '<', $in_reservas_confirmadas) or die "No se pudo abrir '$in_reservas_confirmadas' $!\n";
	@tickets = ();
	while ($linea = <$reservas>) {
		chomp($linea);
		@campos = split (";" , $linea);
		if ($campos[7] eq $id_combo)
		{
			$cant_but_confir = $campos[6];
			if ($debug == 1) {print "Cantidad de tickets a emitir: $cant_but_confir\n";}
			if ($cant_but_confir <= 2) 
			{
				$string = ''; if ($cant_but_confir == 2) {$string = 'S';}
				$un_ticket= "VALE POR $cant_but_confir ENTRADA$string; $campos[1]; $campos[2]; $campos[3]; $campos[5]; $campos[8]; $campos[10] \n";
				print "$un_ticket";
				push(@tickets, $un_ticket);
				
			}
			else {
				local $cant_but_confir_es_impar = $cant_but_confir % 2 == 1; # 0=no, 1=si
								
				#Emito los "vale por 2 entradas" que correspondan
				$cant_vale_por_2 = ($cant_but_confir - $cant_but_confir_es_impar)/2;
				for ($i = 0; $i < $cant_vale_por_2; $i++)
				{
					$un_ticket= "VALE POR 2 ENTRADAS; $campos[1]; $campos[2]; $campos[3]; $campos[5]; $campos[8]; $campos[10] \n";
					print "$un_ticket";
					push(@tickets, $un_ticket);
				}
				
				#Si la cantidad era impar, emito un unico "vale por 1 entrada"
				if ($cant_but_confir_es_impar == 1)
				{
					$un_ticket= "VALE POR 1 ENTRADA; $campos[1]; $campos[2]; $campos[3]; $campos[5]; $campos[8]; $campos[10] \n";
					print "$un_ticket";
					push(@tickets, $un_ticket);
				}
			}
		}
	}

	&escribir_listado_tickets($id_combo, @tickets);
	
	close ($reservas);
}
