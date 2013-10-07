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
$out_invitados_confirmados = "$REPODIR"."/"."$ref".".inv";	#linea
$out_ranking = "$REPODIR"."/ranking."."$nnn";			#linea
$out_tickets = "$REPODIR"."/"."$idcombo".".tck";		#tipo comprobante,nombre obra,fecha funcion,hora funcion,nombre sala,ref int sol,email

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
	print "\t -r: Emite el ranking de los 10 principales (?)"."\n";
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
		
	$resultados = `echo "$resultados" | grep "^[^-]*-$id_obra-.*"`;	#Selecciono por id de obra (2do campo)	
	
	$resultados = `echo "$resultados" | cut -d "-" -f 1-7`;	#Quito el ultimo campo
	print "$resultados";
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
	
	$resultados = `echo "$resultados" | grep "^[^-]*-[^-]*-[^-]*-[^-]*-$id_sala"`;	#Selecciono por id de sala (5to campo)

	$resultados = `echo "$resultados" | cut -d "-" -f 1-7`;	#Quito el ultimo campo
	print "$resultados";
	return ($resultados);
}

sub generar_disponibilidad_por_rango_sala {
	local $min = $_[0];
	local $max = $_[1];
	for ($i=$min; $i <= $max; $i++)
	{
		&generar_disponibilidad_por_s($i);
	}
}

sub escribir_listado_disponibilidad {
	local $out_disponibilidad = "$REPODIR"."/"."$_[0]".".dis";
	
	if ($write == 1)
	{
		open (MYFILE, ">$out_disponibilidad");		#Si el archivo ya existia, se trunca
		print MYFILE "$resultados";					#Escribo en el archivo
		close (MYFILE);
		print "Listado guardado en: $out_disponibilidad\n";
	}
}

sub fInvitados {
	print "fInvitados"."\n";
}

sub fDisp {
	print "fDisp"."\n";
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
		print "Ingrese alguna de las siguientes opciones: \n";
		for ($op = 1; $op < 5; $op++) {
			print "Opcion ".$op.": ".$opciones_fdisp{$op}."\n";
		}
		$opcion_elegida = <STDIN>;
		chomp($opcion_elegida);
	}
	
	# Paso 3: procesar la opción
	if ($opciones_fdisp{$opcion_elegida} eq "ID OBRA")
	{
		pideIDobra:print "Ingrese un ID de obra: ";
		$id_obra = <STDIN>; chomp($id_obra);
		while(&existeIDobra($id_obra) == 0) {
			print "No se encontró ese ID de obra.\n";
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
			print "No se encontró ese ID de sala.\n";
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
			print "Rango inválido.\n"; 
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
			print "Rango inválido.\n"; 
			goto pideRangoIDsala;
		}
		
		print "Rango ID obra válido. \n";
		&generar_disponibilidad_por_rango_sala($min_id_sala,$max_id_sala);
	}
	&escribir_listado_disponibilidad($nombre_listado);
	exit(0);	
}

sub fRanking {
	print "fRanking"."\n";
}

sub fTickets {
	print "fTickets"."\n";
}
