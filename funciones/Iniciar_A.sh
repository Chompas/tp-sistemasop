#!/bin/bash

##############################################################################
# Funciones que emulan arrays asociativos en Bash
##########################################################################
# Funcion que setea un valor en el array asociativo:
# Modo de uso: set nombreArray clave valor

function setArraySimulado {
	NOMBRE_ARRAY=$1
	CLAVE=$2
	VALOR=$3
	eval "local CANTIDAD=\${#$NOMBRE_ARRAY[@]}"
	eval "$NOMBRE_ARRAY[$CANTIDAD]=${CLAVE}:'${VALOR}'"
}

##########################################################################
# Funcion que obtiene el valor de la clave pasada en el array asociativo:
# Modo de uso: get nombreArray clave nombreVariableRetorno

function getArraySimulado {
	local aux=0
	NOMBRE_ARRAY=$1
	CLAVE=$2
	NOMBRE_RETORNO=$3

	eval "local CANTIDAD=\${#$NOMBRE_ARRAY[@]}"
	for (( aux=0; aux<$CANTIDAD; aux++ ));
	do
		eval "local LINEA_ASSOC=\${$NOMBRE_ARRAY[$aux]}"
		VARIABLE=`echo $LINEA_ASSOC | cut -d\: -f1`
		VALOR=`echo $LINEA_ASSOC | cut -d\: -f2`

		if [ $VARIABLE == $CLAVE ]
		then
			eval "$NOMBRE_RETORNO='$VALOR'"
		fi
	done;
}

##########################################################################
# Funcion que obtiene un array con todas las keys del asociado
# Modo de uso: getArraySimuladoClaves nombreArray nombreArrayRetorno

function getArraySimuladoClaves {
	local aux=0
	local NOMBRE_ARRAY=$1
	local NOMBRE_RETORNO=$2

	eval "local CANTIDAD=\${#$NOMBRE_ARRAY[@]}"
	for (( aux=0; aux < $CANTIDAD; aux++ ));
	do
		eval "local LINEA_ASSOC=\${$NOMBRE_ARRAY[$aux]}"
		VARIABLE=`echo $LINEA_ASSOC | cut -d\: -f1`
		eval "$NOMBRE_RETORNO[\${#$NOMBRE_RETORNO[@]}]=$VARIABLE"
	done
}

###############################################################################
# Funcion que informa sobre la configuracion del sistema

function MOSTRAR_RESUMEN() {
	getArraySimulado 'CONFIGURACION' CONFDIR 'CONFDIR'
	echo "- Libreria del Sistema: ${CONFDIR}"
	ls -1 "$GRUPO/${CONFDIR}"
	
	getArraySimulado 'CONFIGURACION' BINDIR 'BINDIR'
	echo "- Ejecutables: ${BINDIR}"
	ls -1 "$GRUPO/${BINDIR}"
	
	getArraySimulado 'CONFIGURACION' MAEDIR 'MAEDIR'
	echo "- Archivos maestros: ${MAEDIR}"
	ls -1 "$GRUPO/${MAEDIR}"

	getArraySimulado 'CONFIGURACION' ARRIDIR 'ARRIDIR'
	echo "- Directorio de arribo de archivos externos: ${ARRIDIR}"

	getArraySimulado 'CONFIGURACION' ACEPDIR 'ACEPDIR'
	echo "- Archivos externos aceptados: ${ACEPDIR}"

	getArraySimulado 'CONFIGURACION' RECHDIR 'RECHDIR'
	echo "- Archivos externos rechazados: ${RECHDIR}"

	getArraySimulado 'CONFIGURACION' REPODIR 'REPODIR'
	echo "- Reportes de salida: ${REPODIR}"
	
	getArraySimulado 'CONFIGURACION' PROCDIR 'PROCDIR'
	echo "- Archivos procesados: ${PROCDIR}"

	getArraySimulado 'CONFIGURACION' LOGDIR 'LOGDIR'
	echo "- Logs de auditoria del Sistema: ${LOGDIR}" 
	echo 
	echo "Estado del sistema: INICIALIZADO"
}	

##########################################################################
# Encabezado
clear
echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"

##########################################################################
# Verifico que el comando no haya sido ejecutado en esta misma sesion

if [ $INICIAR_A_EJECUTADO_EXITOSAMENTE ]
then
	./Grabar_L.sh "Iniciar_A" -t e "El ambiente ya ha sido inicializado en esta sesion."
	echo "La iniciacion ya fue ejecutada en esta sesion de usuario."
	MOSTRAR_RESUMEN
	
else

	echo " "

	##########################################################################
	# Array asociativos donde almacenar las configuraciones de la aplicacion.

	CONFIGURACION=( )
	DIRECTORIOS_EXISTENTES=( )
	ERRORES_DE_INSTALACION=( )
	VARIABLES_FALTANTES=( )

	# Archivo de configuracion
	NUMERO_GRUPO="01"
	ARCHIVO_CONFIGURACION="../conf/Instalar_TP.conf"

	# Arrays asociativos para futura validación de instalación exitosa
	DIRECTORIOS=( 'CONFDIR' 'BINDIR' 'MAEDIR' 'ARRIDIR' 'ACEPDIR' 'RECHDIR' 'REPODIR' 'PROCDIR' 'LOGDIR' )
	DIRECTORIOS_ESCRITURA=( 'CONFDIR' 'ARRIDIR' 'ACEPDIR' 'RECHDIR' 'REPODIR' 'PROCDIR' 'LOGDIR' )
	VARIABLES=('GRUPO' 'CONFDIR' 'BINDIR' 'MAEDIR' 'ARRIDIR' 'ACEPDIR' 'RECHDIR' 'REPODIR' 'PROCDIR' 'LOGDIR' 'LOGEXT' 'LOGSIZE' 'DATASIZE')
	ARCHIVOS_MAESTROS=( 'salas.mae' 'obras.mae' )
	COMANDOS_SISTEMA=( 'Grabar_L.sh' 'Mover_A.sh' 'Recibir_A.sh' 'Start_A.sh' 'Stop_A.sh' 'Reservar_A.sh' 'Imprimir_A.pl' )

	#########################################################################
	# Validacion de existencia del archivo de configuracion
	if [ ! -f "$ARCHIVO_CONFIGURACION" ]
	then
		#exporto unas variables necesarias para el correcto funcionamiento del Grabar en esta instancia
		CONFDIR="conf"
		LOGSIZE=400
		export CONFDIR	
		export LOGSIZE

		./Grabar_L.sh -i "Iniciar_A" -t e "No se pudo iniciar el entorno. No se hallo el archivo de configuracion."
		echo "No se pudo encontrar el archivo de configuracion"
	else

		##########################################################################
		# Chequeo variables de la configuracion
		for (( aux=0; aux<${#VARIABLES[@]}; aux++));
		do
			VARIABLE=${VARIABLES[${aux}]}
			LINEA_CONFIGURACION=`cat $ARCHIVO_CONFIGURACION | grep $VARIABLE`
			
			if [ "$LINEA_CONFIGURACION" ]
			then
				VALOR=`eval echo $LINEA_CONFIGURACION | cut -d\= -f2`                
				setArraySimulado 'CONFIGURACION' "$VARIABLE" "$VALOR"
			else
				ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe la variable $VARIABLE en la configuracion"
			fi
		done

		#########################################################################
		# Verificacion de existencia de los directorios
		getArraySimulado 'CONFIGURACION' 'GRUPO' GRUPO
		for (( aux=0; aux<${#DIRECTORIOS[@]}; aux++)); 
		do
			DIRECTORIO=${DIRECTORIOS[$aux]}
			LINEA_CONFIGURACION=`cat $ARCHIVO_CONFIGURACION | grep $DIRECTORIO`
			
			VARIABLE=`echo $LINEA_CONFIGURACION | cut -d\= -f1`
			VALOR=`eval echo $LINEA_CONFIGURACION | cut -d\= -f2`

			if [ "$LINEA_CONFIGURACION" ]
			then
				if [ -d "$GRUPO/$VALOR" ]
				then
					setArraySimulado 'DIRECTORIOS_EXISTENTES' "$VARIABLE" "$VALOR"
				else
					ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe el directorio ${VARIABLE} en ${VALOR}"
				fi
			else
				VARIABLES_FALTANTES[${#VARIABLES_FALTANTES[@]}]=$DIRECTORIO	
			fi
		done

		#########################################################################
		# Chequeo permisos de escritura en directorios de salida
		for (( aux=0; aux<${#DIRECTORIOS_ESCRITURA[@]}; aux++));      
		do
			getArraySimulado 'DIRECTORIOS_EXISTENTES' ${DIRECTORIOS_ESCRITURA[$aux]} 'DIRECTORIO'
			if [ -d "$GRUPO/$DIRECTORIO" ]
			then
				if [ ! -w "$GRUPO/$DIRECTORIO" ]
				then
					chmod +w "$GRUPO/$DIRECTORIO"
					echo "Fueron seteados permisos. No habia permisos de escritura en el directorio $DIRECTORIO"
				fi
			fi
		done

		#########################################################################
		# Chequeo permisos de archivos
		getArraySimulado 'CONFIGURACION' 'MAEDIR' DIRECTORIO_MAESTROS
		if [ -d "$GRUPO/$DIRECTORIO_MAESTROS" ]
		then
				for ((aux=0; aux<${#ARCHIVOS_MAESTROS[@]}; aux++));
				do
				if [ ! -f "$GRUPO/${DIRECTORIO_MAESTROS}/${ARCHIVOS_MAESTROS[${aux}]}" ]
						then
								ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe el archivo maestro: ${DIRECTORIO_MAESTROS}/${ARCHIVOS_MAESTROS[${aux}]}"

				elif [ ! -r "$GRUPO/${DIRECTORIO_MAESTROS}/${ARCHIVOS_MAESTROS[${aux}]}" ]
						then
								chmod +r "$GRUPO/${DIRECTORIO_MAESTROS}/${ARCHIVOS_MAESTROS[${aux}]}"
								echo "Fueron seteados permisos. No habia permisos de lectura sobre el archivo maestro: ${DIRECTORIO_MAESTROS}/${ARCHIVOS_MAESTROS[${aux}]}"
						fi
				done
		fi

		#########################################################################
		# Verificacion de exitencias de los comandos

		getArraySimulado 'CONFIGURACION' 'BINDIR' DIRECTORIO_EJECUTABLES
		if [ -d "$GRUPO/$DIRECTORIO_EJECUTABLES" ]
		then
			for ((aux=0; aux<${#COMANDOS_SISTEMA[@]}; aux++));
			do
				if [ ! -f "$GRUPO/${DIRECTORIO_EJECUTABLES}/${COMANDOS_SISTEMA[${aux}]}" ]
				then
					ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe el comando: ${DIRECTORIO_EJECUTABLES}/${COMANDOS_SISTEMA[${aux}]}"
				
				elif [ ! -x "$GRUPO/${DIRECTORIO_EJECUTABLES}/${COMANDOS_SISTEMA[${aux}]}" ]
				then	
					chmod +x "$GRUPO/${DIRECTORIO_EJECUTABLES}/${COMANDOS_SISTEMA[${aux}]}"
					echo "Fueron seteados permisos. No habia permisos de ejecucion del comando: ${DIRECTORIO_EJECUTABLES}/${COMANDOS_SISTEMA[${aux}]}"
				fi
			done
		fi

		##########################################################################
		# Seteo variable PATH, solo si se encuentra en la configuracion

		getArraySimulado 'CONFIGURACION' 'BINDIR' DIRECTORIO_EJECUTABLES
		if [ -d "$GRUPO/${DIRECTORIO_EJECUTABLES}" ] 
		then
			PATH=$PATH:"$GRUPO/${DIRECTORIO_EJECUTABLES}"

			CONF=( )
			getArraySimuladoClaves 'CONFIGURACION' CONF

			CANT_VARIABLES=${#CONF[@]}
			for ((aux=0; aux<CANT_VARIABLES; aux++));
			do
				getArraySimulado 'CONFIGURACION' "${CONF[$aux]}" 'VALOR_CONF'
				eval "${CONF[$aux]}='${VALOR_CONF}'; export ${CONF[$aux]}"
			done
		fi

		##########################################################################
		# En caso que existan errores en la instalacion, se muestra el detalle. 

		if [ ${#ERRORES_DE_INSTALACION[@]} -gt 0 ]
		then
			echo "La instalacion no pudo ser concluida. Detalles:"
			for (( aux=0; aux<${#ERRORES_DE_INSTALACION[@]}; aux++ ))
			do
				MSG="${ERRORES_DE_INSTALACION[$aux]}"
				echo "- $MSG"
				./Grabar_L.sh "Iniciar_A" -t e "$MSG"
			done

			getArraySimulado 'CONFIGURACION' 'BINDIR' DIRECTORIO_EJECUTABLES
			if [ -d "$GRUPO/$DIRECTORIO_EJECUTABLES" ]
			then
				echo " "
				echo "Componentes existentes:"
				echo "- Ejecutables:"
				ls -1 "$GRUPO/${DIRECTORIO_EJECUTABLES}"
			fi

			getArraySimulado 'CONFIGURACION' 'MAEDIR' DIRECTORIO_MAESTROS
			if [ -d "$GRUPO/$DIRECTORIO_MAESTROS" ] 
			then
				echo " "
				echo "- Archivos Maestros:"
				ls -1 "$GRUPO/${DIRECTORIO_MAESTROS}"		
			fi

		else

			##########################################################################
			# Inicializo archivo de log
			./Grabar_L.sh "Iniciar_A" -t i "Inicio de ejecución."

			MOSTRAR_RESUMEN

			##########################################################################
			#Funcion para preguntar que accion tomar frente al iniciar Demonio
			funcPreguntarPorDemonio(){
			while true; do
				echo "¿Desea efectuar la activacion de Recibir_A? Si – No" 
					read respuesta
					case $respuesta in
					Si) 
				# Ejecucion del demonio Recibir_A
				bash ./Recibir_A.sh &
				sleep 0.4 
					
				PID_RECIBE=$(ps ax | grep Recibir_A | grep -v Grabar_L | grep -v grep | awk '{print $1}')

				if [ ! -z "$PID_RECIBE" ]
				then
					echo "Demonio corriendo bajo el Nro <$PID_RECIBE>"
					echo "Proceso de inicializacion finalizado con exito."
					echo "Si desea detener el demonio hagalo con el comando Stop_A.sh"
					./Grabar_L.sh "Iniciar_A" -t i "Demonio corriendo bajo el no.: <$PID_RECIBE>"
				else
					echo "Proceso de inicializacion concluido sin exito. No se pudo correr el Demonio."
					./Grabar_L.sh "Iniciar_A" -t e "Inicializacion de Ambiente finalizado con errores."
				fi
				return 0;;
					No) echo "Si desea ejecutar el demonio hagalo con el comando Start_A.sh"
				 return 0;;
					*) echo -e "\nPor favor introduzca Si o No \n";;
				 esac
			done
			}

			##########################################################################
			# Instalacion correctamente finalizada. Chequeo si Recibir_A no esta corriendo actualmente

			PID_RECIBE=`ps ax | grep Recibir_A | grep -v Grabar_L | grep -v grep | awk '{print $1}'`

			if [ $PID_RECIBE ]
			then
				echo " "
				echo "El proceso Recibir_A ya se esta ejecutando con el PID $PID_RECIBE"
				./Grabar_L.sh "Iniciar_A" -t e "No se puede arrancar el demonio. Ya existe otro demonio en ejecucion."

			else	
				funcPreguntarPorDemonio

				# Flag de ejecucion de Iniciar_A exitoso, para chequeo en scripts subsiguientes, de ser necesario
				export INICIAR_A_EJECUTADO_EXITOSAMENTE=1
			fi
		fi
	fi
fi
