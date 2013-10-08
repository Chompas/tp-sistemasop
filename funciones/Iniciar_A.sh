#!/bin/bash


###############################################################################
# Funcion que formatea la informacion de configuracion para ser mostrada 
# en pantalla
function MOSTRAR_RESUMEN() {
	getAssoc 'CONFIGURACION' CONFDIR 'CONFDIR'
	echo "- Libreria del Sistema: ${CONFDIR}"
	ls -1 ${CONFDIR}
	
	getAssoc 'CONFIGURACION' BINDIR 'BINDIR'
	echo "- Ejecutables: ${BINDIR}"
	ls -1 ${BINDIR}
	
	getAssoc 'CONFIGURACION' MAEDIR 'MAEDIR'
	echo "- Archivos maestros: ${MAEDIR}"
	ls -1 ${MAEDIR}

	getAssoc 'CONFIGURACION' ARRIDIR 'ARRIDIR'
	echo "- Directorio de arribo de archivos externos: ${ARRIDIR}"

	getAssoc 'CONFIGURACION' ACEPDIR 'ACEPDIR'
	echo "- Archivos externos aceptados: ${ACEPDIR}"

	getAssoc 'CONFIGURACION' RECHDIR 'RECHDIR'
	echo "- Archivos externos rechazados: ${RECHDIR}"

	getAssoc 'CONFIGURACION' REPODIR 'REPODIR'
	echo "- Reportes de salida: ${REPODIR}"
	
	getAssoc 'CONFIGURACION' PROCDIR 'PROCDIR'
	echo "- Archivos procesados: ${PROCDIR}"

	getAssoc 'CONFIGURACION' LOGDIR 'LOGDIR'
	echo "- Logs de auditoria del Sistema: ${LOGDIR}" 
	echo 
	echo "Estado del sistema: INICIALIZADO"

#TODO	echo "-Demonio corriendo bajo el no.:" #no va aca...
}


###############################################################################
# Funciones que emulan arrays asociativos en BASH
###############################################################################

###############################################################################
# Funcion que setea un valor en el array asociativo:
# Modo de uso:
# set nombreArray clave valor
#
# Ejemplo: setAssoc miArray color rojo
function setAssoc {
	NOMBRE_ARRAY=$1
	CLAVE=$2
	VALOR=$3
	eval "local CANTIDAD=\${#$NOMBRE_ARRAY[@]}"
	eval "$NOMBRE_ARRAY[$CANTIDAD]=${CLAVE}:${VALOR}"
}


###############################################################################
# Funcion que obtiene el valor de la clave pasada en el array asociativo:
# Modo de uso:
# get nombreArray clave nombreVariableRetorno
#
# Ejemplo: getAssoc miArray color miRetorno
function getAssoc {
	local x=0
	NOMBRE_ARRAY=$1
	CLAVE=$2
	NOMBRE_RETORNO=$3

	eval "local CANTIDAD=\${#$NOMBRE_ARRAY[@]}"
	for (( x=0; x<$CANTIDAD; x++ ));
	do
		eval "local LINEA_ASSOC=\${$NOMBRE_ARRAY[$x]}"
		VARIABLE=`echo $LINEA_ASSOC | cut -d\: -f1`
		VALOR=`echo $LINEA_ASSOC | cut -d\: -f2`

		if [ $VARIABLE == $CLAVE ]
		then
			eval "$NOMBRE_RETORNO=$VALOR"
		fi
	done;
}


###############################################################################
# Funcion que obtiene un array con todas las keys del asociativo
# Modo de uso:
# getAssocKeys nombreArray nombreArrayRetorno
#
# Ejemplo: getAssocKeys miArray misClaves
function getAssocKeys {
	local x=0
	local NOMBRE_ARRAY=$1
	local NOMBRE_RETORNO=$2

	eval "local CANTIDAD=\${#$NOMBRE_ARRAY[@]}"
	for (( x=0; x < $CANTIDAD; x++ ));
	do
		eval "local LINEA_ASSOC=\${$NOMBRE_ARRAY[$x]}"
		VARIABLE=`echo $LINEA_ASSOC | cut -d\: -f1`
		eval "$NOMBRE_RETORNO[\${#$NOMBRE_RETORNO[@]}]=$VARIABLE"
	done
}		

###############################################################################
# Encabezado
clear
echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
echo " "
echo " "

###############################################################################
# Verifico que el comando no haya sido ejecutado en esta misma sesion
#TODO sin probar!! falta chequear el llamado al loguear
if [ $INICIAR_A_YA_CORRIO ]
then
	Loguear_A.sh Iniciar_A 'E' '10'
	echo "La iniciacion ya fue ejecutada en esta sesion de usuario."
	MOSTRAR_RESUMEN
	exit 2
else
	INICIAR_A_YA_CORRIO=1
fi
echo 
echo


###############################################################################
# Obtengo las variables del archivo de configuracion y las guardo en un 
# array asociativo donde almacenare las configuraciones de la aplicacion.
# Esta variable va a ser exportada al comando siguiente para su uso.
CONFIGURACION=( )
DIRECTORIOS_EXISTENTES=( )

ERRORES_DE_INSTALACION=( )
VARIABLES_FALTANTES=( )


# Ubicacion del archivo de configuracion
NUMERO_GRUPO="01"
ARCHIVO_CONFIGURACION="${HOME}/.grupo${NUMERO_GRUPO}/Instalar_TP.conf"
#TODO chequear ubicacion del archivo de configurancion


# Arrays asociativos para validación de que la instalación haya finalizado
# con exito.
DIRECTORIOS=( 'CONFDIR' 'BINDIR' 'MAEDIR' 'ARRIDIR' 'ACEPDIR' 'RECHDIR' 'REPODIR' 'PROCDIR' 'LOGDIR' )
DIRECTORIOS_ESCRITURA=( 'CONFDIR' 'ARRIDIR' 'ACEPDIR' 'RECHDIR' 'REPODIR' 'PROCDIR' 'LOGDIR' )
VARIABLES=('GRUPO' 'CONFDIR' 'BINDIR' 'MAEDIR' 'ARRIDIR' 'ACEPDIR' 'RECHDIR' 'REPODIR' 'PROCDIR' 'LOGDIR' 'LOGEXT' 'LOGSIZE')
#TODO chequear nombres de variables y archivos maestros y comandos del sistema
ARCHIVOS_MAESTROS=( 'salas' 'obras' )
COMANDOS_SISTEMA=( 'Loguear_A.sh' 'Mover_A.sh' 'Recibir_A.sh' 'Start_A.sh' 'Reservar_A.sh' 'Imprimir_A.pl' )


##############################################################################
# Validacion de existencia del archivo de configuracion
if [ ! -f "$ARCHIVO_CONFIGURACION" ]
then
#TODO sin probar!! falta chequear el llamado al loguear
	Loguear_A.sh Iniciar_A 'E' '16'
	echo "No se pudo encontrar el archivo de configuracion"
	exit 1
fi


##############################################################################
# Verificacion de existencia de los directorios
for (( x=0;x<${#DIRECTORIOS[@]};x++)); 
do
	DIRECTORIO=${DIRECTORIOS[$x]}
#TODO revisar. dudas
	LINEA_CONFIGURACION=`cat $ARCHIVO_CONFIGURACION | grep -v "^[ ]*#.*$" | grep $DIRECTORIO`
	
	VARIABLE=`echo $LINEA_CONFIGURACION | cut -d\= -f1`
	VALOR=`eval echo $LINEA_CONFIGURACION | cut -d\= -f2`

	if [ "$LINEA_CONFIGURACION" ]
	then
		if [ -d $VALOR ]
		then
			setAssoc 'DIRECTORIOS_EXISTENTES' $VARIABLE $VALOR
		else
			ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe el directorio ${VARIABLE} en ${VALOR}"
		fi
	else
	    VARIABLES_FALTANTES[${#VARIABLES_FALTANTES[@]}]=$DIRECTORIO	
	fi
done


############################################################################ti#
# Verificacion de variables de configuracion
for (( x=0; x<${#VARIABLES[@]}; x++));
do
	VARIABLE=${VARIABLES[${x}]}
#TODO revisar. idem anterior
	LINEA_CONFIGURACION=`cat $ARCHIVO_CONFIGURACION | grep -v "^[ ]*#.*$" | grep $VARIABLE`
	
	if [ "$LINEA_CONFIGURACION" ]
	then
		VALOR=`eval echo $LINEA_CONFIGURACION | cut -d\= -f2`
                
 		setAssoc 'CONFIGURACION' $VARIABLE $VALOR
	else
		ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe la variable $VARIABLE en la configuracion"
	fi

done

##############################################################################
# Verificacion de permisos de escritura en directorios de salida
CANTIDAD_ESCRITURA=${#DIRECTORIOS_ESCRITURA[@]}
for (( x=0;x<$CANTIDAD_ESCRITURA;x++));      
do
	getAssoc 'DIRECTORIOS_EXISTENTES' ${DIRECTORIOS_ESCRITURA[$x]} 'DIRECTORIO'
	if [ -d $DIRECTORIO ]
	then
		if [ ! -w $DIRECTORIO ]
		then
			ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No hay permisos de escritura en el directorio $DIRECTORIO"
		fi
	fi
done


##############################################################################
# Miro permisos de archivos
getAssoc 'CONFIGURACION' 'MAEDIR' DIRECTORIO_MAESTROS
if [ $DIRECTORIO_MAESTROS -a -d $DIRECTORIO_MAESTROS ]
then
        CANT_MAESTROS=${#ARCHIVOS_MAESTROS[@]}
        for ((x=0; x<CANT_MAESTROS; x++));
        do
		if [ ! -f ${DIRECTORIO_MAESTROS}"/"${ARCHIVOS_MAESTROS[${x}]} ]
                then
                        ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe el archivo maestro: ${DIRECTORIO_MAESTROS}${ARCHIVOS_MAESTROS[${x}]}"

		elif [ ! -r ${DIRECTORIO_MAESTROS}"/"${ARCHIVOS_MAESTROS[${x}]} ]
                then
                        ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No hay permisos sobre el archivo maestro: ${DIRECTORIO_MAESTROS}${ARCHIVOS_MAESTROS[${x}]}"
                fi
        done
fi


##############################################################################
# Verificacion de los archivos de comandos
#TODO dudas importantes...
getAssoc 'CONFIGURACION' 'BINDIR' DIRECTORIO_EJECUTABLES
if [ $DIRECTORIO_EJECUTABLES -a -d $DIRECTORIO_EJECUTABLES ]
then
	CANT_COMANDOS=${#COMANDOS_SISTEMA[@]}
	for ((x=0; x<CANT_COMANDOS; x++));
	do
		if [ ! -f ${DIRECTORIO_EJECUTABLES}"/"${COMANDOS_SISTEMA[${x}]} ]
		then
			ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No existe el comando: ${DIRECTORIO_EJECUTABLES}${COMANDOS_SISTEMA[${x}]}"
		
#TODO ops variable x versus -x como "instruccion" trae problemas??
		elif [ ! -x ${DIRECTORIO_EJECUTABLES}"/"${COMANDOS_SISTEMA[${x}]} ]
		then	
			ERRORES_DE_INSTALACION[${#ERRORES_DE_INSTALACION[@]}]="No hay permisos de ejecucion del comando: ${DIRECTORIO_EJECUTABLES}/${COMANDOS_SISTEMA[${x}]}"
		fi
	done
fi



###############################################################################
# Seteo variable PATH, solo si se encuentra en la configuracion
getAssoc 'CONFIGURACION' 'BINDIR' DIRECTORIO_EJECUTABLES
if [ -d ${DIRECTORIO_EJECUTABLES} ] 
then
	PATH=$PATH:${DIRECTORIO_EJECUTABLES}
fi


###############################################################################
# En caso que existan errores en la instalacion, se muestra el detalle, 
# tal como fue indicado en el enunciado.
#TODO no se si el instalador solo deberia estar esto y no aca...
if [ ${#ERRORES_DE_INSTALACION[@]} -gt 0 ]
then
	echo "La instalacion no ha sido concluida. Detalles:"
	for (( x=0;x<${#ERRORES_DE_INSTALACION[@]};x++ ))
	do
		MSG="${ERRORES_DE_INSTALACION[$x]}"
		echo " - $MSG"
	done

	getAssoc 'CONFIGURACION' 'BINDIR' DIRECTORIO_EJECUTABLES
	if [ -d DIRECTORIO_EJECUTABLES ]
	then
		echo
			echo "Componentes existentes:"
			echo " - Ejecutables:"

			ls -1 ${DIRECTORIO_EJECUTABLES}
	fi

	getAssoc 'CONFIGURACION' 'MAEDIR' DIRECTORIO_MAESTROS
	if [ -d $DIRECTORIO_MAESTROS ] 
	then
		echo
		echo " - Archivos Maestros:"

		ls -1 ${DIRECTORIO_MAESTROS}	
	fi
	
	exit 3
fi


###############################################################################
# Inicializo archivo de log
#TODO no chequie llamada al metodo loguear
Loguear_A.sh Iniciar_A 'I' '1'


MOSTRAR_RESUMEN

###############################################################################
# En caso que la instalacion este correctamente finalizada
# me fijo si Recibir_A no esta corriendo actualmente para invocarlo.
#TODO dudas varias...
PID_RECIBE=`ps ax | grep Recibir_A | grep -v Loguear_A | grep -v grep | awk '{print $1}'`

if [ $PID_RECIBE ]
then
	echo
	echo "El proceso Recibir_A ya se esta ejecutando con el PID $PID_RECIBE"
	Loguear_A.sh Iniciar_A 'A' '7'

else
	CONF=( )
	getAssocKeys 'CONFIGURACION' CONF

	CANT_VARIABLES=${#CONF[@]}
	for ((i=0; i<CANT_VARIABLES; i++));
	do
		getAssoc 'CONFIGURACION' "${CONF[$i]}" 'VALOR_CONF'
		eval "${CONF[$i]}=${VALOR_CONF}; export ${CONF[$i]}"
	done
	
	# Flag de ejecucion de Iniciar_A exitoso, para chequeo en scripts subsiguientes.
	INICIAR_A_EJECUTADO_EXITOSAMENTE=1
	export INICIAR_A_EJECUTADO_EXITOSAMENTE

	# Comienzo de ejecucion del demonio Recibir_A
	bash Recibir_A.sh &
	sleep 0.3 
        
	PID_RECIBE=$(ps ax | grep Recibir_A | grep -v Loguear_A | grep -v grep | awk '{print $1}')
	let pid=$PID_RECIBE

	if [ $pid -gt 0 ]
	then
		echo "Demonio corriendo bajo el Nro <$PID_RECIBE>"
		echo "Proceso de inicializacion concluido con exito"
		Loguear_A.sh Iniciar_A 'I' "-Demonio corriendo bajo el no.:" <$PID_RECIBE>"
	else
		echo "Proceso de inicializacion concluido sin exito"
		Loguear_A.sh Iniciar_A 'E' '11'
	fi
fi

