#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	4			#
#	Nombre:	StopD.sh		#
#					#
#########################################



COMANDO="StopD"

chequeaProceso(){

  #El Parametro 1 es el proceso que voy a buscar
  PROC=$1
  PROC_LLAMADOR=$2

  #Busco en los procesos en ejecucion y omito "grep" ya que sino siempre se va a encontrar a si mismo
  # -w es para que busque coincidencia exacta en la palabra porque sino estamos obteniendo cualquier cosa.
  PID=`ps ax | grep -v $$ | grep -v grep | grep -v -w "$PROC_LLAMADOR" | grep $PROC`
  PID=`echo $PID | cut -f 1 -d ' '`
  echo $PID
  
}

RECIBIR_PID=`chequeaProceso Recibir_A.sh $$`
if ([ $RECIBIR_PID ]) then
    kill -9 $RECIBIR_PID
    echo Grabar_L.sh "$COMANDO" "I" "Se detuvo el demonio de Recibir_A con PID: <$RECIBIR_PID>" 
else
   echo Grabar_L.sh "$COMANDO" "I" "No se pudo detener el demonio Recibir_A pues no fue encontrado"
fi


