#!/bin/bash
cantidadLineasADejar=5		# Cantidad de lineas luego de truncar
cantidadParametros=$#
esLogInstalacion=false		# Fue invocado por el instalador?
debug=true

if $debug ; then
	LOGEXT="log"
	LOGDIR="dirLogs"
	CONFDIR="dirLogsInstalacion"
	LOGSIZE=100
fi

# Array asociativo con los tipos posibles de mensajes
declare -A tiposMensajes
tiposMensajes=([i]=Info [w]=Warning [e]=Error [se]=Severe)

# Imprime la forma correcta de uso de este script
function uso() { 
	echo "Uso: $0 [-i] comando [-t <i|w|e|se>] mensaje" 1>&2;
	echo "Parámetros opcionales:"
	echo -e "\t-i: El modulo invocante es el instalador del TP."
	echo -e "\t-t: Tipo de mensaje a loggear:"
	for tipo in "${!tiposMensajes[@]}"
	do
		echo -e "\t\t$tipo: ${tiposMensajes[$tipo]}."
	done
	exit 1;
}

# ------- COMIENZO PROCESAMIENTO DE ARGUMENTOS -------- 
# Mas info: http://wiki.bash-hackers.org/howto/getopts_tutorial
# Hay un parametro opcional "-i", y un parámetro opcional "-h"
while getopts "hi" opt; do
    case "${opt}" in
		h)		# Muestra la ayuda del script y finaliza
			uso
			return 0
			;;
        i)
			esLogInstalacion=true            
            ;;
    esac
done

if [ "$OPTIND" != 1 ] ; then
	shift $(( OPTIND-1 ))		# $2 se convierte en $1
fi
comando="$1"

OPTIND=2
# Hay un parametro opcional "-t", que lleva un argumento (el tipo de mensaje)
while getopts "t:" opt; do
    case "${opt}" in
        t)
			s="${OPTARG}"
			tipoInvalido=true
			for tipo in "${!tiposMensajes[@]}"
			do
				if [ "$s" == "$tipo" ]; then
					tipoInvalido=false
				fi
			done
			if $tipoInvalido ; then
				uso
				return 0
			else
				tipoMensaje=$s
			fi
            ;;
    esac
done

if [ "$OPTIND" != 1 ] ; then
	shift $(( OPTIND-2 ))		# $2 se convierte en $1
fi
mensaje="$2"

# ------- FIN PROCESAMIENTO DE ARGUMENTOS -------- 

directorio=$LOGDIR
extension=$LOGEXT
if $esLogInstalacion ; then
	directorio=$CONFDIR
	extension="log"
fi
tamanioMaximoLog=$LOGSIZE
nombreArchivoDeLog=${comando}.${extension}
path=${directorio}/${nombreArchivoDeLog}
fecha=$(date +"%d-%m-%y %T")
usuario=$USER

if $debug ; then
	echo "esLogInstalacion = "$esLogInstalacion
	echo "comando = "$comando
	echo "tipo mensaje = "$tipoMensaje
	echo "mensaje = "$mensaje
	echo "path = "$path
fi

# Si el archivo no existe
if [ ! -f $path ]; then
	# Si el directorio no existe
    if [ ! -d $directorio ]; then
		mkdir -m 775 $directorio # Creamos el directorio
	fi
	
	# Creamos el archivo con el encabezado
	echo -e "FECHA \t \t \t USUARIO \t COMANDO \t TIPO \t \t MENSAJE" >> $path
fi

# Si el archivo es muy grande, y no es el log de instalación, lo truncamos
tamanioArchivo=$(stat -c '%s' $path)
if $debug ; then 
	echo "tamanio archivo = "$tamanioArchivo
fi
if [ "$tamanioArchivo" -ge "$tamanioMaximoLog" ]; then
	if ! $esLogInstalacion ; then
		echo -e "FECHA \t \t \t USUARIO \t COMANDO \t TIPO \t \t MENSAJE" >> ${path}_tmp
		tail --lines=$cantidadLineasADejar $path >> ${path}_tmp
		rm $path
		mv ${path}_tmp $path
		echo "Log Excedido" >> $path
	fi
fi

# Finalmente... escribimos en el archivo de log!!!
echo -e "$fecha \t $usuario \t $comando \t ${tiposMensajes[$tipoMensaje]} \t \t $mensaje" >> $path

exit 0
