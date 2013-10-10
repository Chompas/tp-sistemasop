#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	4			#
#	Nombre:	startD.sh		#
#					#
#########################################



COMANDO="StartD"

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

chequeaVariables(){

  if ( [ "$BINDIR" != "" ]  && [ "$GRUPO" != "" ] && [ "$ARRIDIR" != "" ] && [ "$RECHDIR" != "" ] && [ "$MAEDIR" != "" ] ) then
    echo 0
  else
    echo 1
  fi

}

chequeaArchivosMaestros(){

  MAEDIR="./MAEDIR"
  OBRAS="$MAEDIR/obras.mae"
  SALAS="$MAEDIR/salas.mae"

  #Chequeo que los archivos existan  
  if [ ! -f $OBRAS ] ; then
      echo 1
      return
  fi
  
  if [ ! -f $SALAS ] ; then
    echo 1
    return
  fi
  
  #Chequeo que los archivos tengan permisos de lectura
  if [ ! -r "$OBRAS" ] ; then
    echo 1
    return
  fi
  
  if [ ! -r "$SALAS" ] ; then
    echo 1
    return
  fi
  
  
  echo 0
  return
}


chequeaDirectorios(){

  # Chequeo que existan los directorios
  if ([ ! -d "$GRUPO" ] && [ ! -d "$LOGDIR" ] && [ ! -d "$MAEDIR" ] && [ ! -d "$ARRIDIR" ] && [ ! -d "$RECHDIR" ]) then
    echo 1
    return
  fi
  echo 0
  return
}


  # Si alguna variable no esta definida error en la instalación
  if [ `chequeaVariables` -eq 1 ] ; then
    echo 1
  fi

  #CHEQUEAR INSTALACION

  if [ `chequeaDirectorios` -eq 1 ] ; then
    echo Grabar_L.sh "$COMANDO" "SE" "Directorios necesarios no creados en la instalacion o no disponibles" 
    echo "Error: Directorios necesarios no creados en la instalacion o no disponibles"
    exit 1
  fi
  
  if [ `chequeaArchivosMaestros` -eq 1 ] ; then
    echo Grabar_L.sh "$COMANDO" "SE" "Archivos maestros no accesibles/disponibles"
    echo "Error: Archivos maestros no accesibles/disponibles"
    exit 1
  fi

#Detecto si Recibir_A esta corriendo
  RECIBIR_PID=`chequeaProceso Recibir_A.sh $$`
  if [ -z "$RECIBIR_PID" ]; then
  
    bash Recibir_A.sh &
    echo Recibir_A.sh "$COMANDO" "I" "Demonio Recibir_A corriendo bajo el numero de proceso: <`chequeaProceso Recibir_A.sh $$`>" 
  else
    echo Recibir_A.sh "$COMANDO" "E" "Demonio Recibir_A ya ejecutado bajo PID: <`chequeaProceso Recibir_A.sh $$`>" 
    echo "Error: Demonio Recibir_A ya ejecutado bajo PID: <`chequeaProceso Recibir_A.sh $$`>"
    exit 1
  fi