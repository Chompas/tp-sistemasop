#!/bin/bash
cantidadLineasADejar=5			# Cantidad de lineas luego de truncar
esLogInstalacion=false			# Fue invocado por el instalador?
tipoMensaje=""					# Tipo de mensaje de error
debug=false

if $debug ; then
	LOGEXT="logext"
	LOGDIR="dirLogs"
	CONFDIR="dirLogsInstalacion"
	LOGSIZE=`echo "4*1024" | bc`
fi

# Array asociativo con los tipos posibles de mensajes
declare -A tiposMensajes
tiposMensajes=([i]=Info [w]=Warning [e]=Error [se]=Severe)

# Imprime la forma correcta de uso de este script
function uso() { 
	echo "Uso: $0 [-i] comando [-t <i|w|e|se>] mensaje" 1>&2;
	echo "Descripción: Escribe en el archivo de log el <comando> que generó el mensaje, y el <mensaje>."
	echo "Si el archivo de log no existe, lo crea con el nombre <comando>." 
	echo "Si existe, escribe en una línea nueva al final del archivo."
	echo "Si el archivo de log es muy grande, lo trunca y luego escribe."
	echo "Parámetros opcionales:"
	echo -e "\t-i: El modulo invocante es el instalador del TP."
	echo -e "\t-t: Tipo de mensaje a loggear:"
	for tipo in "${!tiposMensajes[@]}"
	do
		echo -e "\t\t$tipo: ${tiposMensajes[$tipo]}."
	done
	exit 1;
}

function escribe_header_log() {
	echo -e "FECHA Y HORA-USUARIO-COMANDO-TIPO MENSAJE-MENSAJE" 	
}

# ------- COMIENZO PROCESAMIENTO DE ARGUMENTOS -------- 
# Mas info: http://wiki.bash-hackers.org/howto/getopts_tutorial
# Hay un parametro opcional "-i", y un parámetro opcional "-h"
while getopts "hi" opt; do
    case "${opt}" in
		h)		# Muestra la ayuda del script y finaliza
			uso
			exit 0
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

directorio="$GRUPO/$LOGDIR"
extension="$LOGEXT"
if $esLogInstalacion ; then
	comando="Instalar_TP"
	directorio="$GRUPO/$CONFDIR"
	extension="log"
fi
tamanioMaximoLog=`echo "$LOGSIZE*1024" | bc`
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
if [ ! -f "$path" ]; then
	# Si el directorio no existe
    if [ ! -d "$directorio" ]; then
		mkdir -m 775 "$directorio" # Creamos el directorio
	fi
	
	# Creamos el archivo con el encabezado
	escribe_header_log >> "$path"
fi

# Si el archivo es muy grande, y no es el log de instalación, lo truncamos
tamanioArchivo=$(stat -c '%s' "$path")
if $debug ; then 
	echo "tamanio archivo = "$tamanioArchivo
fi
if [ "$tamanioArchivo" -ge "$tamanioMaximoLog" ]; then
	if ! $esLogInstalacion ; then
		escribe_header_log >> ${path}_tmp
		tail --lines=$cantidadLineasADejar "$path" >> ${path}_tmp
		rm $path
		mv ${path}_tmp "$path"
		echo "Log Excedido" >> "$path"
	fi
fi

# Obtenemos el tipo de mensaje (completo)
tipo=""
if [ "$tipoMensaje" != "" ] ; then
	tipo=${tiposMensajes[$tipoMensaje]}
fi

# El mensaje debe tener hasta 120 caracteres
mensajeTruncado=${mensaje:0:120}
if $debug ; then
	echo "mensaje truncado = $mensajeTruncado"
fi

# Finalmente... escribimos en el archivo de log!!!
echo -e "$fecha-$usuario-$comando-$tipo-$mensajeTruncado" >> "$path"

exit 0
