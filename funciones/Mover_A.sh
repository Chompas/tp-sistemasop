#!/bin/bash
#Parámetro 1 (obligatorio): origen (archivo)
#Parámetro 2 (obligatorio): destino (directorio)
#Parámetro 3 (opcional): comando que la invoca
#Otros parámetros u opciones a especificar por el desarrollador

debug=false

if $debug ; then
	PATH=$PATH:.
fi

function uso() { 
	echo "Uso: $0 origen destino [comando]" 1>&2;
	echo "Mueve el archivo <origen> al directorio <destino>. En caso de ser invocada por un comando que graba en un archivo de log, debe pasarse el nombre del mismo como <comando>"
	echo "En caso de archivos duplicados, genera el directorio dup en <destino> con el archivo duplicado"
	exit 1;
}

while getopts "h" opt; do
    case "${opt}" in
		h)		# Muestra la ayuda del script y finaliza
			uso
			return 0
			;;
    esac
done

# Los parametros deben ser 2 o 3
if [ $# -gt 3 -o $# -lt 2 ]; then
    echo "Cantidad de parametros invalida"
    exit 1
fi

origen="$1"
dirDestino="$2"
if [ $# -eq 3 ]; then
	comando="$3"
fi	
dirOrigen="${1%/*}"
nombreOrigen="${1##/*}"

# Verificar si el origen y el destino son iguales. Si este fuera el caso, no mover
if [ $dirOrigen = $dirDestino ]; then
	if [ $# -eq 3 ]; then
		./Grabar_L.sh "$comando" -t w "Origen y destino iguales. No se mueve"
	fi	
	exit 0
fi

# Si el origen no existe o el destino no existe, error. Si este fuera el caso, no mover
if [ ! -f $origen ]; then
	if [ $# -eq 3 ]; then
		./Grabar_L.sh "$comando" -t e "$origen no existe"
	fi	
    exit 1
fi
if [ ! -d $dirDestino ]; then
	if [ $# -eq 3 ]; then
		./Grabar_L.sh "$comando" -t e "$dirDestino no existe"
	fi	
    exit 1
fi

# Verificar si es un archivo duplicado
if [ -f $dirDestino/$nombreOrigen ]; then
    # Archivo duplicado
    if [ ! -d "$dirDestino/dup" ]; then
        mkdir "$dirDestino/dup"
    fi
    nnn=$(ls "$dirDestino/dup" | grep "^$nombreOrigen.[0-9]\{1,3\}$" | sort -r -V | sed s/$nombreOrigen.// | head -n 1)
	if [ "$nnn" == "" ]; then
	    nnn=0
	fi
	nnn=$(echo $nnn +1 | bc -l)
	if [ $# -eq 3 ]; then
		./Grabar_L.sh "$comando" -t w "Archivo duplicado"
	fi	
	mv "$origen" "$dirDestino/dup/$nombreOrigen.$nnn"
	
else
    # Archivo no duplicado
    mv "$origen" "$dirDestino"
fi
exit 0

