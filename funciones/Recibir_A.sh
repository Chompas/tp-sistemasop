#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	1			#
#	Nombre:	Recibir_A.sh		#
#					#
#########################################


#
# 1. Verificar inicialización del ambiente y que no haya otro demonio corriendo
# 
# 2. Chequea la existencia de archivos en ARRIDIR
# 
# 3. Se ejecuta el Reservar_A.sh
#



#source global.sh
COMANDO="Recibir_A.sh"


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

agregarVariablePath(){
  #echo $PATH
  NEWPATH=`pwd`
  export PATH=$PATH:$NEWPATH
  #echo $PATH
}


chequeaXXX(){
  XXX=$1
  ESPACIO=`contieneEspacio $XXX`
  GUION=`contieneGuion $XXX`  
  if ( [ $ESPACIO == "1" ] || [ $GUION == "1" ] ) then
     echo "1"
  else
     echo "0"
  fi
}

contieneEspacio(){
  echo $1 | grep -q '.* .*'
  if ([ $? -eq 0 ]) then 
	echo "1"
  else
	echo "0"
  fi
}

contieneGuion(){
  echo $1 | grep -q '.*-.*'
  if ([ $? -eq 0 ]) then 
	echo "1"
  else
	echo "0"
  fi
}


#main()


# esto se va a comentar luego. Inicia afuera
LOOP=true
CANT_LOOP=1
ESPERA=10
#ARRIDIR="ARRIDIR"
#ACEPDIR="ACEPDIR"
#RECHDIR="RECHDIR"
#REPODIR="REPODIR"
#MAEDIR="MAEDIR"
#GRUPO="../TPSSOOMIO"
SALAS="$GRUPO/$MAEDIR"'/salas.mae'
OBRAS="$GRUPO/$MAEDIR"'/obras.mae'
HASTA=2
#path="Logs"

if ([ ! -d "$GRUPO/$ARRIDIR/" ]) then
#  llamar con bash al loguear
   bash Grabar_L.sh "$comando" -t se "$GRUPO/$ARRIDIR/ no existe"
   exit 1
fi

if ([ ! -d "$GRUPO/$ACEPDIR/" ]) then
   bash Grabar_L.sh "$comando" -t se "$GRUPO/$ACEPDIR/ no existe"
   exit 1
fi

if ([ ! -d "$GRUPO/$RECHDIR/" ]) then
   bash Grabar_L.sh "$comando" -t se "$GRUPO/$RECHDIR/ no existe"
   exit 1
fi

if ([ ! -d "$GRUPO/$REPODIR/" ]) then
   bash Grabar_L.sh "$comando" -t se "$GRUPO/$REPODIR/ no existe"
   exit 1
fi

if ([ ! -d "$GRUPO/$MAEDIR/" ]) then
   bash Grabar_L.sh "$comando" -t se "$GRUPO/$ARRIDIR/ no existe"
   exit 1
fi

if ( [ ! -f "$SALAS" ] ) then
   bash Grabar_L.sh "$comando" -t se "No existe el archivo maestro $SALAS"
   exit 1
fi

if ( [ ! -f "$OBRAS" ] ) then
   bash Grabar_L.sh "$comando" -t se "No existe el archivo maestro $OBRAS"
   exit 1
fi


#while ([ $CANT_LOOP -lt $HASTA ])
while ([ $CANT_LOOP ])
do
   bash Grabar_L.sh "$comando" -t i "Comienzo de ciclo: $CANT_LOOP"
   if ([ -d "$GRUPO/$ARRIDIR" ]) then
	IFS="
"
#        ARCHIVOS=`ls -p "$GRUPO/$ARRIDIR" | grep -v '/$'`
#        for PARAM in $ARCHIVOS	
#        do  
        ARCHIVOS=`ls -p "$GRUPO/$ARRIDIR" | grep -v '/$'`
        for PARAM in $ARCHIVOS	
        do  

	  
	  #echo "PARAM: $PARAM"
          case "$PARAM" in 
	  *-*-*) VALNAME=`echo "RESERVA"`;;
	  *.inv) VALNAME=`echo "INVITADO"`;;
          *) VALNAME=`echo "incorrecto"`;;
          esac 

	  if ([ "$VALNAME" = "RESERVA" ]) then

	    #echo "RESERVA"         
            ID=`echo "$PARAM" | cut -f 1 -d '-'`
            MAIL=`echo "$PARAM" | cut -f 2 -d '-'`
            XXX=`echo "$PARAM" | cut -f 3 -d '-'`
	    XXX2=`echo "$PARAM" | cut -f 4 -d '-'`
	    XXXVALIDO=`chequeaXXX $XXX` 

	    #echo "ID: $ID"
            #echo "MAIL: $MAIL"
            #echo "XXX: $XXX"
	    #echo "XXX2: $XXX2"
	    if ([ $XXXVALIDO == "0" ] && [ ! $XXX2 ]) then
	       #echo "SALAS: $SALAS"
	       if ( [ -f "$SALAS" ] && [ -f "$OBRAS" ] ) then
    	          a=`LANG=C grep "^$ID;[^;]*;[^;]*;[^;]*;[^;]*;$MAIL" -n $SALAS | cut -f1 -d';'`
    	          b=`LANG=C grep "^$ID;[^;]*;$MAIL;[^;]*" -n $OBRAS | cut -f1 -d';'`
    	          c=`LANG=C grep "^$ID;[^;]*;[^;]*;$MAIL" -n $OBRAS | cut -f1 -d';'`
		  #echo "a: $a"
		  #echo "b: $b"
		  #echo "c: $c"
	          if ([ $a ] || [ $b ] || [ $c ]) then
  	             bash Mover_A.sh "$GRUPO/$ARRIDIR/$PARAM"  "$GRUPO/$ACEPDIR"
		     bash Grabar_L.sh "$COMANDO" -t i "Archivo $PARAM enviado"  		     
                  else
		     bash Mover_A.sh "$GRUPO/$ARRIDIR/$PARAM"  "$GRUPO/$RECHDIR"
	 	     bash Grabar_L.sh "$COMANDO" -t e "$PARAM rechazado por no existir combinación de ID-MAIL en los maestros"
                  fi
               else
                 bash Grabar_L.sh "$COMANDO" -t se "No existe el archivo maestro de salas o de obras"
               fi
	    else
	      bash Mover_A.sh "$GRUPO/$ARRIDIR/$PARAM"  "$GRUPO/$RECHDIR"	
	      bash Grabar_L.sh "$COMANDO" -t e "$PARAM es rechazado porque XXX contiene guiones o blancos"
	    fi
          fi

	  if ([ "$VALNAME" = "INVITADO" ]) then
		XXX=`echo "$PARAM" | cut -f 1 -d '.'`
		XXXVALIDO=`chequeaXXX $XXX` 
	    	if ([ $XXXVALIDO == "0" ]) then
  	             bash Mover_A.sh "$GRUPO/$ARRIDIR/$PARAM"  "$GRUPO/$REPODIR"
		     bash Grabar_L.sh "$COMANDO" -t i "Archivo $PARAM enviado"  
                  else
		     bash Mover_A.sh "$GRUPO/$ARRIDIR/$PARAM"  "$GRUPO/$RECHDIR"
	 	     bash Grabar_L.sh "$COMANDO" -t e "$PARAM rechazado por nombre inválido"
		fi 
	  fi 

	  if ([ "$VALNAME" = "incorrecto" ]) then
             bash Mover_A.sh "$GRUPO/$ARRIDIR/$PARAM"  "$GRUPO/$RECHDIR"
	     bash Grabar_L.sh "$COMANDO" -t i "Archivo $PARAM rechazado por nombre inválido"  
	  fi 
        done
   else
     echo "No Existe $ARRIDIR!"
   fi

   let CANT_LOOP=CANT_LOOP+1



   ENACEPDIR=`ls -1 "$GRUPO/$ACEPDIR" | wc -l | awk '{print $1}'`

   #echo "ENRECIBIDOS $ENACEPDIR"
   if ([ $ENACEPDIR -gt 0 ]) then
      RESERVARA_PID=`chequeaProceso Reservar_A.sh $$`
      if [ -z "$RESERVARA_PID" ]; then
	  bash Reservar_A.sh &
#	  x=1	  
      else
          echo "Reservar_A ya ejecutado bajo PID: <$RESERVARA_PID>" 
      fi
   fi

   sleep ${ESPERA}s
done

LOOP=0
   	
exit 0

