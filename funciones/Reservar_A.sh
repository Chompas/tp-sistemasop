#!/bin/bash

# combo.dis
# campo1 ID DEL COMBO Numérico (clave)
# campo2 ID DE LA OBRA numérico
# campo3 FECHA DE FUNCIÓN formato: día/mes/año
# campo4 HORA DE FUNCIÓN formato: hh:mm
# campo5 ID DE LA SALA numérico
# campo6 BUTACAS HABILITADAS numérico
# campo7 BUTACAS DISPONIBLES numérico
# campo8 REQUISITOS ESPECIALES caracteres

# reservas.nok
# campo1 REFERENCIA INTERNA DEL SOLICITANTE
# campo2 FECHA DE FUNCIÓN
# campo3 HORA DE FUNCIÓN
# campo4 NRO. DE FILA
# campo5 NRO. DE BUTACA
# campo6 CANTIDAD DE BUTACAS SOLICITADAS
# campo7 SECCION
# Campo8 MOTIVO
# campo9 ID de la SALA
# campo10 ID de la OBRA
# campo11 CORREO DEL SOLICITANTE
# campo12 USUARIO GRABACION
# campo13 FECHA GRABACION



debug=false

if $debug ; then
	ACEPDIR="../aceptados"
	PROCDIR="../procesados"
	RECHDIR="../rechazados"
	MAEDIR="../mae"
fi

function cantidadArchivos() {
	echo $(find "$1" -type f | wc -l)
}

function horaValida() {
	
	if [[ $1 =~ ^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$ ]]
	then
		return 0
	else
		return 1
	fi
}

function fechaValida() {
	IFS='/' read -ra FECHACAMPO <<< "$1"
	fechaInvertida="${FECHACAMPO[2]}/${FECHACAMPO[1]}/${FECHACAMPO[0]}"
	
	fechaRegT=`date --date="$fechaInvertida" +%s 2> /dev/null`
	
	if [ -z $fechaRegT ]
	then
		return 1
	else
		return 0
	fi
}

function obtenerNombre() {
	rem=$(( $1 % 2 ))
	if [ $rem -eq 0 ]
	then
		#SALAS
		match=$(LANG=C grep "^$1;.*$" "$GRUPO/$MAEDIR/salas.mae")
	else
		#OBRAS
		match=$(LANG=C grep "^$1;.*$" "$GRUPO/$MAEDIR/obras.mae")
	fi
	IFS=';' read -ra CAMPOS_MAE <<< "$match"
	# 0: id
	# 1: nombre
	# etc
	echo ${CAMPOS_MAE[1]}
	
}


function existeEvento() {
	filename=$1
	rem=$(( $filename % 2 ))
	if [ $rem -eq 0 ]
	then
		#SALAS
		match=$(grep "^[^;]*;[^;]*;$2;$3;$1;.*$" "$GRUPO/$PROCDIR/combos.dis")
		idSala=$filename
	else
		#OBRAS
		match=$(grep "^[^;]*;$1;$2;$3;.*$" "$GRUPO/$PROCDIR/combos.dis")
		idObra=$filename
	fi
		
	# Devuelve true si match es vacio
	IFS=';' read -ra CAMPOS_MATCH <<< "$match"
	# 0: id del combo
	# 6: butacas disponibles	
	
	# combo.dis
	# campo1 ID DEL COMBO Numérico (clave)
	# campo2 ID DE LA OBRA numérico
	# campo3 FECHA DE FUNCIÓN formato: día/mes/año
	# campo4 HORA DE FUNCIÓN formato: hh:mm
	# campo5 ID DE LA SALA numérico
	# campo6 BUTACAS HABILITADAS numérico
	# campo7 BUTACAS DISPONIBLES numérico
	# campo8 REQUISITOS ESPECIALES caracteres
	
	
	if [ -z $match ]
	then
		numeroEvento=0
	else
		existeFuncionEnMemoria=1;
		if [ $rem -eq 0 ]
		then
			#SALAS
			idObra=${CAMPOS_MATCH[1]}
		else
			#OBRAS
			idSala=${CAMPOS_MATCH[4]}
		fi
		for idFuncion in "${IDS_FUNCIONES[@]}"
		do
			if [ $idFuncion = ${CAMPOS_MATCH[0]} ]
			then
				existeFuncionEnMemoria=0
			fi
		done
		if [ $existeFuncionEnMemoria = 1 ]
		then
			IDS_FUNCIONES+=(${CAMPOS_MATCH[0]})
			DISP_FUNCIONES+=(${CAMPOS_MATCH[6]})
		fi
		numeroEvento=${CAMPOS_MATCH[0]}
	fi
}

function reservarEvento() {
	
	#Parametros:
	# ${CAMPOS_FILENAME[0]} ${CAMPOS[1]} ${CAMPOS[2]} ${CAMPOS[5]} $numeroEvento ${CAMPOS[0]} ${CAMPOS_FILENAME[1]}
	
	idEvento=$5
	dispSolicitada=$4
	index=0
	position=-1
	# Busco en el array de IDS
	for id in "${IDS_FUNCIONES[@]}"
	do
		if [ $idEvento = $id ]
		then
			position=$index
		fi
		index=$(expr $index + 1)
	done
	
	disponibilidad=${DISP_FUNCIONES[$position]}
	if [ $dispSolicitada -le $disponibilidad ]
	then
		disponibilidad=$(expr $disponibilidad - $dispSolicitada)
		DISP_FUNCIONES[$position]=$disponibilidad


		# Armo registro de registro.ok
		
		# campo1 ID de la OBRA 
		# Campo2 NOMBRE DE LA OBRA (del archivo de obras)
		# Campo3 FECHA DE FUNCIÓN
		# Campo4 HORA DE FUNCIÓN
		# Campo5 ID de la SALA
		# Campo6 NOMBRE DE LA SALA (del archivo de salas)
		# Campo7 CANTIDAD DE BUTACAS CONFIRMADAS
		# Campo8 ID del COMBO
		# Campo9 REFERENCIA INTERNA DEL SOLICITANTE
		# Campo10 CANTIDAD DE BUTACAS SOLICITADAS
		# Campo11 CORREO DEL SOLICITANTE
		# campo12 USUARIO GRABACION
		# campo13 FECHA GRABACION

		obra=$idObra
		#VOY A BUSCAR A OBRAS.mae EL ID Y TRAER EL NOMBRE DE LA OBRA
		nombreObra=$(obtenerNombre $obra)
		fechaFuncion=$2
		horaFuncion=$3
		sala=$idSala
		#IDEM OBRAS pero para salas
		nombreSala=$(obtenerNombre $sala)
		cantidadButacasConf=$dispSolicitada
		idCombo=$idEvento
		if [ -z $7 ]
		then
			correo=$6
		else
			refInterna=$6
			correo=$7
		fi
		
		cantidadButacasSolic=$dispSolicitada
		user=$USER
		fechaGrabacion=$(date +"%Y/%m/%d") #FORMATO A DETERMINAR
		
		nuevoRegistro="$idObra;$nombreObra;$fechaFuncion;$horaFuncion;$idSala;$nombreSala;$cantidadButacasConf;$idCombo;$refInterna;$cantidadButacasSolic;$correo;$user;$date"
		echo $nuevoRegistro >> $GRUPO/$PROCDIR/reservas.ok
		
		cantidadOK=$((cantidadOK+1))
		
		return 0;
	else
		return 1;
	fi
}

function rechazar() {
	local_array=("${@}")
    motivo=${local_array[0]}
    refInt=${local_array[1]}
    fecha=${local_array[2]}
    hora=${local_array[3]}
    fila=${local_array[4]}
    butaca=${local_array[5]}
    cantSolicitada=${local_array[6]}
    seccion=${local_array[7]}
	if [ idSala = 0 ]
	then
		sala="falta sala"
	else
		sala=$idSala
	fi
	if [ idObra = 0 ]
	then
		obra="falta obra"
	else 
		obra=$idObra
	fi
    correo=${local_array[9]}
    user=$USER
    date=$(date +"%Y/%m/%d") #FORMATO A DETERMINAR
    
    nuevoRegistro="$refInt;$fecha;$hora;$fila;$butaca;$cantSolicitada;$seccion;$motivo;$sala;$obra;$correo;$user;$date"
    echo $nuevoRegistro >> "$GRUPO/$PROCDIR/reservas.nok"
        
    cantidadNOK=$((cantidadNOK+1))
    
}

# MAIN

IDS_FUNCIONES=()
DISP_FUNCIONES=()
numeroEvento=0
idObra=0
idSala=0
cantidadOK=0
cantidadNOK=0

# 1. Inicializar log
./Grabar_L.sh "Reservar_A" -t i "Inicio de Reservar"
cant=$(cantidadArchivos "$GRUPO/$ACEPDIR")
./Grabar_L.sh "Reservar_A" -t i "Cantidad de Archivos en $GRUPO/$ACEPDIR: $cant"

# Me fijo si ya esta corriendo
lockFile=/tmp/pIdGrabarLockFile
cat /dev/null >> $lockFile
read lastPID < $lockFile
if [ ! -z "$lastPID" -a -d /proc/$lastPID ] 
then
	echo "Reservar_A ya esta corriendo"
	exit
else
	echo $$ > $lockFile
fi

# Si no hay archivos
if [ $cant = 0 ]
then
	./Grabar_L.sh "Reservar_A" -t e "No hay archivos a procesar"
	exit 1;
fi


IFS=$(echo -en "\n\b")
# Recorro archivos a procesar
ACEPFILES="$GRUPO/$ACEPDIR/*"
# 2. Procesar Un Archivo
for f in $ACEPFILES
do
	./Grabar_L.sh "Reservar_A" -t i "Archivo a procesar: $f"
	
	IFS='-' read -ra CAMPOS_FILENAME <<< "${f##*/}"
	# 0: id obra o sala
	# 1: correo
	# 2: xxx
	
	# Verifico que el archivo no fue procesado
	# 3. Verificar que no sea un archivo duplicado
	
	if [ -f "$GRUPO/$PROCDIR/${f##*/}" ]
	then
		# Archivo ya existe. Lo rechazo
		./Grabar_L.sh "Reservar_A" -t w "Se rechaza el archivo por estar DUPLICADO"
		./Mover_A.sh $f "$GRUPO/$RECHDIR" "Reservar_A"
	elif [ ! -s $f ]
	then
		# 4. Archivo vacio. Lo rechazo
		./Grabar_L.sh "Reservar_A" -t w "Se rechaza el archivo por estar VACIO"
		./Mover_A.sh $f "$GRUPO/$RECHDIR" "Reservar_A"
	else
		
		# Proceso archivo
		while read reg || [ -n "$reg" ]
		#for reg in `cat "$f"`
		do
			IFS=';' read -ra CAMPOS <<< "$reg"
			# 0: (referencia interna)
			# 1: fecha de funcion
			# 2: hora de funcion
			# 3: (fila)
			# 4: (butaca)
			# 5: cantidad de butacas solicitadas
			# 6: (seccion)
			
			existeEvento ${CAMPOS_FILENAME[0]} ${CAMPOS[1]} ${CAMPOS[2]}
			
			# 5.1.a Validar fecha
			if ! fechaValida ${CAMPOS[1]}
			then
				rechazar "Fecha invalida" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
			else
				
				fechaActual=$(date +"%Y/%m/%d")
				fechaActualT=`date --date="$fechaActual" +%s`
				IFS='/' read -ra FECHACAMPO <<< "${CAMPOS[1]}"
				fechaInvertida="${FECHACAMPO[2]}/${FECHACAMPO[1]}/${FECHACAMPO[0]}"
				fechaRegT=`date --date="$fechaInvertida" +%s`
				
				let "dif=$fechaRegT-$fechaActualT"
				# Obtengo la diferencia en dias
				let "dayDif=dif/60/60/24"
							
				# 5.1.b Si la reserva esta vencida
				if [ $dayDif -lt 1 ]
				then
					rechazar "Reserva tardia" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
				# 5.1.c Si la reserva es superior a 45 dias
				elif [ $dayDif -gt 45 ]
				then
					rechazar "Reserva anticipada" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
				# 5.2 Verifico formato hora (hh:mm)
				elif  ! horaValida ${CAMPOS[2]} 
				then
					rechazar "Hora invalida" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}" 
				# 5.3 Verifico que exista la funcion
				else 
					if [ $numeroEvento = 0 ]
					then
						rechazar "No existe el evento solicitado" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
					# 5.4 Chequeo de disponibilidad y realizo la reserva de estar todo ok
					elif ! reservarEvento ${CAMPOS_FILENAME[0]} ${CAMPOS[1]} ${CAMPOS[2]} ${CAMPOS[5]} $numeroEvento ${CAMPOS[0]} ${CAMPOS_FILENAME[1]}
					then 
						rechazar "Falta de disponibilidad" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
					fi
				fi
			fi
		done < $f
		./Mover_A.sh $f "$GRUPO/$PROCDIR" "Reservar_A"
	fi
done

./Grabar_L.sh "Reservar_A" -t i "Cantidad de registros grabados en reservas.ok: $cantidadOK"
./Grabar_L.sh "Reservar_A" -t i "Cantidad de registros grabados en reservas.nok: $cantidadNOK"

index=0
for id in "${IDS_FUNCIONES[@]}"
do
	dispId=${DISP_FUNCIONES[$index]}
	sed -i "s-\(^$id;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\)[0-9]*\(;[^;]*$\)-\1$dispId\2-g" "$GRUPO/$PROCDIR/combos.dis"
	
index=$(expr $index + 1)
done

# 9 Cerrar el Log
./Grabar_L.sh "Reservar_A" -t i "Fin de Reservar_A"
