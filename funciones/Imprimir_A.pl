#!/usr/bin/perl

# Variables generales
$debug = 1;						# Debuggeando? 0=no, 1=si
$write = 0;						# Va a escribir en archivo? 0=no, 1=si
$ambiente_inicializado = 1;		# Ambiente inicializado? 0=no, 1=si
$en_ejecucion = 0;				# Hay otra instancia en ejecucion? 0=no, 1=si

if ($debug == 1)
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
$in_invitados = "$REPODIR/"."$ref".".inv"; 	#invitado[;empresa[;cantidad acompanantes]]

# Archivos de output
$out_invitados_confirmados = "$REPODIR"."/"."$ref".".inv";

# ---------- INICIO COMPROBACIONES DE RUTINA ------------
if ($ambiente_inicializado == 0)
{
	print "ERROR: el ambiente no fue inicializado. \n";
	exit(1);
}
if ($en_ejecucion == 1)
{
	print "ERROR: hay otra instancia del script en ejecución. \n";
	exit(1);
}
# ---------- FIN COMPROBACIONES DE RUTINA ------------

# ---------- INICIO PROCESAMIENTO ARGUMENTOS ------------
%opciones = ("-i" => \&fInvitados, "-d" => \&fDisp, "-r" => \&fRanking, "-t" => \&fTickets);

$num_argv = $#ARGV +1;

if ($num_argv == 0) {
	print "ERROR: faltan parámetros.\n";
	&uso;exit(1);
}
if (($num_argv > 2) || ($ARGV[0] eq "-a")) {
	&uso;exit(1);
}
elsif (($num_argv == 2) && ($ARGV[0] eq "-w")) 
{
	$write = 1;
	if ( exists($opciones{$ARGV[1]}) )	#Si existe la opcion
	{
		&{$opciones{$ARGV[1]}};		#Llamo a la funcion correspondiente
	}
}
elsif (($num_argv == 1) && (exists($opciones{$ARGV[0]}))) 
{
	&{$opciones{$ARGV[0]}};
}
else {
	print "ERROR: parámetros incorrectos.\n";
	&uso;exit(1);
}

if ($debug == 1)
{
	print "write = $write \n";
	print "num argv = $num_argv \n";
	print "argv[0] = $ARGV[0] \n";
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
	print "fInvitados"."\n";
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
