#!/bin/bash
cantidadLineasADejar=5		# Cantidad de lineas luego de truncar
cantidadParametros=$#
esModuloInstalador=false	# Fue invocado por el instalador?
debug=false

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
		h)
			uso
			return 0
			;;
        i)
			esModuloInstalador=true            
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

LOGDIR="dirLogs"
LOGEXT="log"
LOGSIZE=1000
nombreArchivoDeLog=${comando}.$LOGEXT
path=${LOGDIR}/${nombreArchivoDeLog}
fecha=$(date)
usuario=$USER

if $debug ; then
	echo "esModuloInstalador = "$esModuloInstalador
	echo "comando = "$comando
	echo "tipo mensaje = "$tipoMensaje
	echo "mensaje = "$mensaje
	echo "path = "$path
	echo "tamanioArchivo = "$tamanioArchivo
fi

# Si el archivo no existe
if [ ! -f $path ]; then
	# Si el directorio no existe
    if [ ! -d $LOGDIR ]; then
		mkdir -m 775 $LOGDIR # Creamos el directorio
	fi
	
	# Creamos el archivo con el encabezado
	echo -e "FECHA \t \t \t USUARIO \t COMANDO \t TIPO \t \t MENSAJE" >> $path
fi

# Si el archivo es muy grande, lo truncamos
tamanioArchivo=$(stat -c '%s' $path)
if [ "$tamanioArchivo" -ge "$LOGSIZE" ]; then
	echo -e "FECHA \t USUARIO \t COMANDO \t TIPO \t MENSAJE" >> ${path}_tmp
	tail --lines=$cantidadLineasADejar $path >> ${path}_tmp
	rm $path
	mv ${path}_tmp $path
	echo "Log Excedido" >> $path		# El parametro -n es para evitar el fin de linea
fi

# Finalmente... escribimos en el archivo de log!!!
echo -e "$fecha \t $usuario \t ${tiposMensajes[$tipoMensaje]} \t $mensaje" >> $path

exit 0
