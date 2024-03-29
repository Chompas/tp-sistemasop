#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	1			#
#	Nombre:	Start_A.sh		#
#					#
#########################################

COMANDO="Start_A"

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
  if ( [ "$CONFDIR" != "" ] && [ "$BINDIR" != "" ] && [ "$MAEDIR" != "" ] && [ "$ARRIDIR" != "" ] && [ "$ACEPDIR" != "" ] && 
       [ "$RECHDIR" != "" ] && [ "$REPODIR" != "" ] && [ "$PROCDIR" != "" ] && [ "$LOGDIR" != "" ] && [ "$GRUPO" != "" ] &&
       [ "$LOGEXT" != "" ] &&[ "$LOGSIZE" != "" ] &&  [ "$DATASIZE" != "" ] ) then
    echo 0
  else
    echo 1
  fi

}

chequeaArchivosMaestros(){

  #Chequeo que los archivos existan  
  if [ ! -f "$OBRAS" ] ; then
      echo 1
      return
  fi
  
  if [ ! -f "$SALAS" ] ; then
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
  if ([ ! -d "$GRUPO" ] || [ ! -d "$GRUPO/$BINDIR" ] || [ ! -d "$GRUPO/$MAEDIR" ] || [ ! -d "$GRUPO/$ARRIDIR" ] || 
      [ ! -d "$GRUPO/$ACEPDIR" ] || [ ! -d "$GRUPO/$RECHDIR" ] || [ ! -d "$GRUPO/$REPODIR" ] || [ ! -d "$GRUPO/$PROCDIR" ] || 
      [ ! -d "$GRUPO/$LOGDIR" ]) then
    echo 1
    return
  fi
  echo 0
  return
}


  # Si alguna variable no esta definida error en la instalación

debug=false
if $debug; then
   CONFDIR="CONFDIR"
   BINDIR="BINDIR"
   MAEDIR="MAEDIR"
   ARRIDIR="ARRIDIR"
   ACEPDIR="ACEPDIR"
   RECHDIR="RECHDIR"
   REPODIR="REPODIR"
   PROCDIR="PROCDIR"
   LOGDIR="LOGDIR"
   GRUPO="../TPSSOOMIO"
   LOGEXT="LOGEXT"
   LOGSIZE=1000
   DATASIZE=1000
   SALAS="$GRUPO/$MAEDIR/salas.mae"
   OBRAS="$GRUPO/$MAEDIR/obras.mae"
fi

   SALAS="$GRUPO/$MAEDIR/salas.mae"
   OBRAS="$GRUPO/$MAEDIR/obras.mae"

  if [ `chequeaVariables` -eq 1 ] ; then
    bash Grabar_L.sh "$COMANDO" -t e "No se hayan inicializadas las variables necesarias. No se puede llamar al Recibir_A"
    echo "ERROR: No se hallan inicializadas las variables necesarias. No se puede llamar al Recibir_A."
    exit 1
  fi

  #CHEQUEAR INSTALACION
  if [ `chequeaDirectorios` -eq 1 ] ; then
    bash Grabar_L.sh "$COMANDO" -t se "Directorios necesarios no creados en la instalacion o no disponibles" 
    echo "ERROR: Directorios necesarios no creados en la instalación o no disponibles."
    exit 1
  fi
  
  if [ `chequeaArchivosMaestros` -eq 1 ] ; then
    bash Grabar_L.sh "$COMANDO" -t se "Archivos maestros no accesibles/disponibles"
    echo "ERROR: Archivos maestros no accesibles/disponibles."
    exit 1
  fi

#Detecto si Recibir_A esta corriendo
  RECIBIR_PID=`chequeaProceso Recibir_A.sh $$`
  if [ -z "$RECIBIR_PID" ]; then
  
    bash Recibir_A.sh &
    bash Grabar_L.sh "$COMANDO" -t i "Demonio Recibir_A corriendo bajo el numero de proceso: <`chequeaProceso Recibir_A.sh $$`>" 
    echo "Demonio Recibir_A corriendo bajo el numero de proceso: <`chequeaProceso Recibir_A.sh $$`>." 
  else
    bash Grabar_L.sh "$COMANDO" -t e "Demonio Recibir_A ya ejecutado bajo PID: <`chequeaProceso Recibir_A.sh $$`>" 
    echo "ERROR: Demonio Recibir_A ya ejecutado bajo PID: <`chequeaProceso Recibir_A.sh $$`>."
    exit 1
  fi
