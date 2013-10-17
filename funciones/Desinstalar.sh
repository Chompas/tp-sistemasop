#!/bin/bash
#-------------------------------------------- #
# Script encargado de desinstalar el sistema. #
# Se busca una instalación previa, en caso de #
# encontrarla, se cargan las rutas desde el   #
# respectivo archivo de configuración.        #
# HIP: Se vuelven a cargar las variables,     #
#      pues puede darse el caso de querer     #
#      desinstalar el paquete sin antes haber #
#      ejecutado Iniciar_Tp.sh.               #
#---------------------------------------------#

function salir() {
	exit 0
}

if [ ! -f "../conf/Instalar_TP.conf" ]; then
	echo "ERROR: No hay ninguna instalación previa."
	salir
fi

GRUPO=`grep "^GRUPO=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
BINDIR=`grep "^BINDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
MAEDIR=`grep "^MAEDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
ARRIDIR=`grep "^ARRIDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
ACEPDIR=`grep "^ACEPDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
RECHDIR=`grep "^RECHDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
PROCDIR=`grep "^PROCDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
REPODIR=`grep "^REPODIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
LOGDIR=`grep "^LOGDIR=.*$" "../conf/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`

echo "¿Está seguro que desea desisntalar la aplicación? Todos los datos se perderán. (Si-No)"
echo ""
INPUT="0"
while [ "$INPUT" != 'No' ] && [ "$INPUT" != 'Si' ]; do  # falla con cadena vacia
	read INPUT
	AUX=`echo $INPUT | sed 's-^$-X-'`
	if [ $AUX == 'No' ];
	then
		salir	
	fi
	INPUT=$AUX
done

rm -r "$GRUPO/$BINDIR"

if [ $MAEDIR != "mae" ]; then
	rm -r "$GRUPO/$MAEDIR"
fi

rm -r "$GRUPO/$ARRIDIR"
rm -r "$GRUPO/$ACEPDIR"
rm -r "$GRUPO/$RECHDIR"
rm -r "$GRUPO/$PROCDIR"
rm -r "$GRUPO/$REPODIR"
rm -r "$GRUPO/$LOGDIR"
rm -r "$GRUPO/conf"

salir
