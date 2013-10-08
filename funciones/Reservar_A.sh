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



debug=true

if $debug ; then
	ACEPDIR="grupo1/aceptados"
	PROCDIR="grupo1/proc"
	RECHDIR="grupo1/rechazados"
fi

function cantidadArchivos() {
	echo $(find $1 -type f | wc -l)
}

function horaValida() {
	
	if [[ $1 =~ ^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$ ]]
	then
		return 0
	else
		return 1
	fi
}

function existeEvento() {
	#SOLO PARA ID DE OBRAS FALTA COMPROBACION CON ID DE SALAS
	match=$(grep "^.*;$1;$2;$3;.*$" $PROCDIR/combos.dis)
	# Devuelve true si match es vacio
	IFS=';' read -ra CAMPOS_MATCH <<< "$match"
	# 0: id del combo
	# 6: butacas disponibles	
	
	if [ -z $match ]
	then
		echo 0
	else
		existeFuncionEnMemoria=1;
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
		echo ${CAMPOS_MATCH[0]}
	fi
}

function reservarEvento() {
	echo "reservar"
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
    #FALTAN ID SALA O OBRA QUE ME LO TENGO QUE TRAER DE COMBOS
    correo=${local_array[9]}
    user=$USER
    date=$(date +"%Y/%m/%d") #FORMATO A DETERMINAR
    
    nuevoRegistro="$refInt;$fecha;$hora;$fila;$butaca;$cantSolicitada;$seccion;$motivo;;;$correo;$user;$date"
    echo $nuevoRegistro >> $PROCDIR/reservas.nok
    
    #EN SECCION ME TRAE UN \n -> TODO: SACARLO!!!!
    
    #TODO: CONTAR REGISTROS GUARDADOS
    
}

# MAIN

IDS_FUNCIONES=()
DISP_FUNCIONES=()

# Inicializar log
./Grabar_L.sh "Reservar_A" -t i "Inicio de Reservar"
cant=$(cantidadArchivos $ACEPDIR)
./Grabar_L.sh "Reservar_A" -t i "Cantidad de Archivos en $ACEPDIR: $cant"

# Si no hay archivos
if [ $cant = 0 ]
then
	./Grabar_L.sh "Reservar_A" -t e "No hay archivos a procesar"
	exit 1;
fi


# Recorro archivos a procesar
ACEPFILES="$ACEPDIR/*"

for f in $ACEPFILES
do
	./Grabar_L.sh "Reservar_A" -t i "Archivo a procesar: $f"
	
	IFS='-' read -ra CAMPOS_FILENAME <<< "${f##*/}"
	# 0: id obra o sala
	# 1: correo
	# 2: xxx
	
	# Verifico que el archivo no fue procesado
	
	if [ -f $PROCDIR/${f##*/} ]
	then
		# Archivo ya existe. Lo rechazo
		./Grabar_L.sh "Reservar_A" -t w "Se rechaza el archivo por estar DUPLICADO"
		./Mover_A.sh $f $RECHDIR "Reservar_A"
	elif [ ! -s $f ]
	then
		# Archivo vacio. Lo rechazo
		./Grabar_L.sh "Reservar_A" -t w "Se rechaza el archivo por estar VACIO"
		./Mover_A.sh $f $RECHDIR "Reservar_A"
	else
		# Proceso archivo
		while read reg
		do
			IFS=';' read -ra CAMPOS <<< "$reg"
			# 0: (referencia interna)
			# 1: fecha de funcion
			# 2: hora de funcion
			# 3: (fila)
			# 4: (butaca)
			# 5: cantidad de butacas solicitadas
			# 6: (seccion)
			
			
			#TODO: Validar fecha
			
			
			fechaActual=$(date +"%Y/%m/%d")
			fechaActualT=`date --date="$fechaActual" +%s`
			IFS='/' read -ra FECHACAMPO <<< "${CAMPOS[1]}"
			fechaInvertida="${FECHACAMPO[2]}/${FECHACAMPO[1]}/${FECHACAMPO[0]}"
			fechaRegT=`date --date="$fechaInvertida" +%s`
			
			let "dif=$fechaRegT-$fechaActualT"
			# Obtengo la diferencia en dias
			let "dayDif=dif/60/60/24"
						
			# Si la reserva esta vencida
			if [ $dayDif -lt 1 ]
			then
				rechazar "Reserva tardia" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
			# Si la reserva es superior a 45 dias
			elif [ $dayDif -gt 45 ]
			then
				rechazar "Reserva anticipada" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
			# Verifico formato hora (hh:mm)
			elif  ! horaValida ${CAMPOS[2]} 
			then
				rechazar "Hora invalida" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
			# Verifico que exista la funcion
			else 
				numeroEvento=$(existeEvento ${CAMPOS_FILENAME[0]} ${CAMPOS[1]} ${CAMPOS[2]})
				if [ $numeroEvento = 0 ]
				then
					rechazar "No existe el evento solicitado" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
				# Chequeo de disponibilidad y realizo la reserva de estar todo ok
				elif ! reservarEvento ${CAMPOS_FILENAME[0]} ${CAMPOS[1]} ${CAMPOS[2]} ${CAMPOS[5]} $numeroEvento ${CAMPOS[0]} ${CAMPOS_FILENAME[1]}
				then 
					rechazar "Falta de disponibilidad" "${CAMPOS[@]}" "${CAMPOS_FILENAME[@]}"
				fi
			fi
			
		done < $f
	fi
	
done
