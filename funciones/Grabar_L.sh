#!/bin/bash
cantidadLineasADejar=5			# Cantidad de lineas luego de truncar
esLogInstalacion=false			# Fue invocado por el instalador?
tipoMensaje=""					# Tipo de mensaje de error
debug=false

if $debug ; then
	GRUPO="1"
	LOGEXT="logext"
	LOGDIR="dirLogs"
	CONFDIR="dirLogsInstalacion"
	LOGSIZE=`echo "4*1024" | bc`
fi

cte_tiposMensajes=("i" "w" "e" "se")
cte_mensajes=("Info" "Warning" "Error" "Severe Error")

# Imprime la forma correcta de uso de este script
function uso() { 
	echo "Uso: $0 [-i] comando [-t <i|w|e|se>] mensaje" 1>&2;
	echo "Descripción: Escribe en el archivo de log el <comando> que generó el mensaje, y el <mensaje>."
	echo "Si el archivo de log no existe, lo crea con el nombre <comando>." 
	echo "Si existe, escribe en una línea nueva al final del archivo."
	echo "Si el archivo de log es muy grande, lo trunca para dejar $cantidadLineasADejar líneas y luego escribe."
	echo "Parámetros opcionales:"
	echo -e "\t-i: El módulo invocante es el instalador."
	echo -e "\t-t: Tipo de mensaje a loggear:"
	
	for i in ${!cte_tiposMensajes[*]} 
	do
		echo -e "\t\t ${cte_tiposMensajes[$i]}: ${cte_mensajes[$i]}."	
	done
	exit 1;
}

function escribe_header_log() {
	echo -e "FECHA Y HORA-USUARIO-COMANDO-TIPO MENSAJE-MENSAJE" 	
}

# ------- COMIENZO PROCESAMIENTO DE ARGUMENTOS -------- 

# La cantidad de parámetros debe ser entre 2 y 5
if [ $# -lt 2 -o $# -gt 5  ]; then
	uso
	exit 0
fi

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
			# Verifico que sea un tipo de mensaje válido
			for i in ${!cte_tiposMensajes[*]} 
			do
				if [ "$s" == "${cte_tiposMensajes[$i]}" ]; then
					tipoInvalido=false
					pos_tipoMensaje=$i
					tipoMensaje=$s
				fi
			done
			if $tipoInvalido ; then
				uso
				return 0
			fi
            ;;
    esac
done

if [ "$OPTIND" != 1 ] ; then
	shift $(( OPTIND-2 ))		# $2 se convierte en $1
fi
mensaje="$2"

# ------- FIN PROCESAMIENTO DE ARGUMENTOS -------- 

if $esLogInstalacion ; then
	comando="Instalar_TP"
	directorio="$GRUPO/$CONFDIR"
	extension="log"
else
	directorio="$GRUPO/$LOGDIR"
	extension="$LOGEXT"
fi

tamanioMaximoLog=`echo "$LOGSIZE*1024" | bc`
path=${directorio}/${comando}.${extension}
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
		mkdir "$directorio" # Creamos el directorio
	fi
	
	# Creamos el archivo con el encabezado
	escribe_header_log >> "$path"
fi

tamanioArchivo=$(stat -c '%s' "$path")
if $debug ; then 
	echo "tamanio archivo = "$tamanioArchivo
fi

# Si el archivo es muy grande, y no es el log de instalación, lo truncamos
if [ "$tamanioArchivo" -ge "$tamanioMaximoLog" ]; then
	if ! $esLogInstalacion ; then
		escribe_header_log >> ${path}_tmp
		tail --lines=$cantidadLineasADejar "$path" >> ${path}_tmp
		rm $path
		mv ${path}_tmp "$path"
		echo "Log Excedido" >> "$path"
	fi
fi

# El mensaje debe tener hasta 120 caracteres
mensajeTruncado=${mensaje:0:120}
if $debug ; then
	echo "mensaje truncado = $mensajeTruncado"
fi

# Finalmente... escribimos en el archivo de log!!!
echo -e "$fecha-$usuario-$comando-${cte_mensajes[$pos_tipoMensaje]}-$mensajeTruncado" >> "$path"

exit 0
