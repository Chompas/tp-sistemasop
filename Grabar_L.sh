#!/bin/bash
cantidadLineasADejar=5		# Cantidad de lineas luego de truncar
cantidadParametros=$#
esModuloInstalador=false	# Fue invocado por el instalador?

# Array asociativo con los tipos posibles de mensajes
declare -A tiposMensajes
tiposMensajes=([i]=Info [w]=Warning [e]=Error [se]=Severe)

# Imprime la forma correcta de uso de este script
function uso() { 
	echo "Uso: $0 [-i] comando [-t <i|w|e|se>] mensaje" 1>&2;
	echo -e "\t-i: El modulo invocante es el instalador del TP"
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

shift $(( OPTIND-1 ))		# $N se convierte en $N-1
comando="$1"

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

if [ "$cantidadParametros" -gt 2 ] ; then
	shift $(($OPTIND - 2))
fi
mensaje="$2"

# ------- FIN PROCESAMIENTO DE ARGUMENTOS -------- 

echo "esModuloInstalador = "$esModuloInstalador
echo "comando = "$comando
echo "tipo mensaje = "$tipoMensaje
echo "mensaje = "$mensaje

LOGDIR="directorio"
LOGEXT="log"
LOGSIZE=500
nombreArchivoDeLog=${comando}.$LOGEXT
path=${LOGDIR}/${nombreArchivoDeLog}

echo "path = " $path

# Si el archivo no existe
if [ ! -f path ]; then
	# Si el directorio no existe
    if [ ! -d $LOGDIR ]; then
		mkdir -m 775 $LOGDIR # Creamos el directorio
	fi
	
	echo -n "" >> $path # Creamos el archivo
fi

tamanioArchivo=$(stat -c '%s' Grabar_L.sh)
echo "tamanioArchivo = " $tamanioArchivo

if [ $tamanioArchivo -ge $LOGSIZE ]; then
	# Truncamos el archivo
	tail --lines=$cantidadLineasADejar $path >> ${path}_tmp
	rm $path
	mv ${path}_tmp $path
	echo -n "Log Excedido" >> $path		# El parametro -n es para evitar el fin de linea
fi
exit 0
