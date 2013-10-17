#!/bin/bash

# Funciones auxiliares
function auxValidaDirectorio() {
	var=`echo "$1"  | grep "^[-_ /a-zA-Z0-9]*$" | grep "^[^/].*"`
	if [ "$var" ] ; then
		var1="`echo "$var" | grep "^.*//.*"`"
		if [ "$var1" ] ; then
			echo "Invalido"
			return 1;
		fi
		var2="`echo "$var1" | grep "^/.*$"`"
		if [ ! "$var2" ]; then
			echo "Valido"
			return 0;
		else
			echo "Invalido"
			return 1;
		fi
	else
		echo "Invalido"
		return 1;
	fi
}

function chequearBash() {
	bashVersion=`bash --version | grep "^[^,]*, version \([^(]*\).*$" | sed "s/^[^,]*, version \([^(]*\).*$/\1/" | sed "s/^\([^.]\).*$/\1/"`
	if [ $bashVersion -lt 4 ]; then
		echo "ERROR: La versión de bash es inválida. Debe tener instalado Bash 4.x.x o superior."
		fin
	fi
}

# 1. Iniciar archivo de log
iniciarLogDeInstalacion() {
	# Iniciar el archivo
	echo 'Inicio de Ejecución'
	./Grabar_L.sh -i "Instalar_TP" -t i "Inicio de Ejecución"
}

# 2. Mostrar (y grabar en el log) donde se graba el log de la instalación
mostrarUbicacionDelLogDeInstalacion() {
	echo "Log del Comando Instalar_TP: $CONFDIR/Instalar_TP.log"
	./Grabar_L.sh -i "Instalar_TP" -t i "Log del Comando Instalar_TP: $CONFDIR/Instalar_TP.log"
}

# 3. Mostrar (y grabar en el log)  el nombre del directorio de configuración
mostrarDirectorioDeConfiguracion() {
	echo "Directorio de Configuración: $CONFDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Directorio de Configuración: $CONFDIR"
}

verificarExistenciaComponentes(){
	
	for componente in `ls "$GRUPO/$BINDIR"`
	do
		if [ "Iniciar_A.sh" = "$componente" ]
		then
		   	iniciar_a_file=1
		elif [ "Recibir_A.sh" = "$componente" ]
		then
			recibir_a_file=1
		elif [ "Reservar_A.sh" = "$componente" ]
		then
			reservar_a_file=1
		elif [ "Start_A.sh" = "$componente" ]
		then
			start_a_file=1
		elif [ "Stop_A.sh" = "$componente" ]
		then
			stop_a_file=1
		elif [ "Mover_A.sh" = "$componente" ]
		then
			mover_a_file=1
		elif [ "Imprimir_A.pl" = "$componente" ]
		then
			imprimir_a_file=1
		elif [ "Grabar_L.sh" = "$componente" ]
		then
			grabar_l_file=1
		fi
    done

	if [ $iniciar_a_file -eq 1 ] && [ $recibir_a_file -eq 1 ] && [ $reservar_a_file -eq 1 ] && [ $start_a_file -eq 1 ] && [ $stop_a_file -eq 1 ]  && [ $mover_a_file -eq 1 ] && [ $imprimir_a_file -eq 1 ] && [ $grabar_l_file -eq 1 ] 
	then
		echo "Estado de la instalación: COMPLETA."
		./Grabar_L.sh -i "Instalar_TP" -t i "Estado de la instalación: COMPLETA"

		echo "Proceso de instalación Cancelado."
		./Grabar_L.sh -i "Instalar_TP" -t i "Proceso de Instalación Cancelado"
	else
		echo "Componentes faltantes:"
		./Grabar_L.sh -i "Instalar_TP" -t i "Componentes faltantes:"

		imprimirComponentesFaltantes
		echo "Estado de la instalación: INCOMPLETA."
		./Grabar_L.sh -i "Instalar_TP" -t i "Estado de la instalación: INCOMPLETA"

		echo "¿Desea completar la instalación? (Si-No)"
		./Grabar_L.sh -i "Instalar_TP" -t i "Desea completar la instalación? (Si-No)"

		INPUT="0"
		while [ "$INPUT" != 'No' ] && [ "$INPUT" != 'Si' ]; do  # falla con cadena vacia
		    read INPUT

            	    ./Grabar_L.sh -i "Instalar_TP" -t i "$INPUT"

		    AUX=`echo $INPUT | sed 's-^$-X-'`
		    if [ $AUX == 'No' ];
		    then
		        fin
		    fi
		    INPUT=$AUX
		done
		# indico si

		chequearPerl
		verEstructura
		confirmarInicio
	fi 	
}

imprimirComponentesFaltantes() {
	if [ $iniciar_a_file -eq 0 ] 
	then
		echo "Iniciar_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Iniciar_A.sh"
	fi
	if [ $recibir_a_file -eq 0 ]
	then
		echo "Recibir_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Recibir_A.sh"
	fi
	if [ $reservar_a_file -eq 0 ]
	then
		echo "Reservar_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Reservar_A.sh"
	fi
	if [ $start_a_file -eq 0 ] 
	then
		echo "Start_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Start_A.sh"
	fi
	if [ $stop_a_file -eq 0 ] 
	then
		echo "Stop_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Stop_A.sh"
	fi	
	if [ $mover_a_file -eq 0 ] 
	then
		echo "Mover_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Mover_A.sh"
	fi
	if [ $imprimir_a_file -eq 0 ] 
	then
		echo "Imprimir_A.pl"
		./Grabar_L.sh -i "Instalar_TP" -t i "Imprimir_A.pl"
	fi
	if  [ $grabar_l_file -eq 0 ]
	then
		echo "Grabar_L.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Grabar_L.sh"
	fi
}

# 4. Detectar si el paquete RESER_A  o alguno de sus componentes ya está instalado.
verificarInstalacionPrevia() {
	if [ -f "$GRUPO/$CONFDIR/Instalar_TP.conf" ]
	then
	    # Determinar si esta completo y faltantes
		echo "Librería del sistema: $GRUPO/$CONFDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Librería del sistema: $GRUPO/$CONFDIR"
		
		ls "$GRUPO/$CONFDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "`ls "$GRUPO/$CONFDIR"`"

		echo "Ejecutables: $GRUPO/$BINDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Ejecutables: $GRUPO/$BINDIR"

		ls "$GRUPO/$BINDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "`ls "$GRUPO/$BINDIR"`"

		echo "Archivos Maestros: $GRUPO/$MAEDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos Maestros: $GRUPO/$MAEDIR"

		ls "$GRUPO/$MAEDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "`ls "$GRUPO/$MAEDIR"`"

		echo "Directorio de arribo de archivos externos: $GRUPO/$ARRIDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio de arribo de archivos externos: $GRUPO/$ARRIDIR"

		echo "Archivos externos aceptados: $GRUPO/$ACEPDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos aceptados: $GRUPO/$ACEPDIR"

		echo "Archivos externos rechazados: $GRUPO/$RECHDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos rechazados: $GRUPO/$RECHDIR"

		echo "Reportes de salida: $GRUPO/$REPODIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Reportes de salida: $GRUPO/$REPODIR"

		echo "Archivos procesados: $GRUPO/$PROCDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos procesados: $GRUPO/$PROCDIR"

		echo "Logs de auditoria del Sistema: $GRUPO/$LOGDIR/<comando>.$LOGEXT"
		./Grabar_L.sh -i "Instalar_TP" -t i "Logs de auditoria del Sistema: $GRUPO/$LOGDIR/<comando>.$LOGEXT"

		verificarExistenciaComponentes
	    	fin
	fi
}

# 5. Aceptar terminos y Condiciones
aceptarTerminosyCondiciones() {
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01
A T E N C I Ó N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa 
aceptar los términos y Condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" 
incluido en este paquete.
¿Acepta? Si – No"
	./Grabar_L.sh -i "Instalar_TP" -t i "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
	./Grabar_L.sh -i "Instalar_TP" -t i "A T E N C I Ó N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa
aceptar los términos y Condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete."
	./Grabar_L.sh -i "Instalar_TP" -t i "¿Acepta? Si – No"

	INPUT="0"
	while [ "$INPUT" != 'No' ] && [ "$INPUT" != 'Si' ]; do  # falla con cadena vacia

	    read INPUT
	    ./Grabar_L.sh -i "Instalar_TP" -t i "$INPUT"

	    AUX=`echo $INPUT | sed 's-^$-X-'`
	    if [ $AUX == 'No' ];
	    then
        	# 5.1. Si el usuario indica No, ir a FIN
	        fin
	    fi
	    INPUT=$AUX
	done
}

# 6. Chequear instalacion PERL 5 o superior.
chequearPerl(){
	chequeo_perl=`whereis perl`
	if [ "$chequeo_perl" != "perl: " ] 
	then
		local chequeo_perl=`perl --version | grep 'v[0-9]\.' | sed "s/.*v\([^.]\).*/\1/"`
		if [ $chequeo_perl -ge 5 ]
		then
			existePerl;
		else
			noExistePerl;
		fi
	else
		noExistePerl;
	fi
}

# 6.1 
noExistePerl() {
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01
Para instalar el TP es necesario contar con Perl 5 o superior
instalado. 
Efectúe su instalación e inténtelo nuevamente.
Proceso de Instalación Cancelado."

	./Grabar_L.sh -i "Instalar_TP" -t i "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
	./Grabar_L.sh -i "Instalar_TP" -t i "Para instalar el TP es necesario contar con Perl 5 o superior instalado."
	./Grabar_L.sh -i "Instalar_TP" -t i "Efectúe su instalación e inténtelo nuevamente."
	./Grabar_L.sh -i "Instalar_TP" -t i "Proceso de Instalación Cancelado"
	
	fin
}

# 6.2
existePerl() {
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01
Perl Version: $chequeo_perl"

	./Grabar_L.sh -i "Instalar_TP" -t i "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
	./Grabar_L.sh -i "Instalar_TP" -t i "Perl Version: $chequeo_perl"
}

# 7. Definir el directorio de instalación de los ejecutables
definirDirectorioEjecutables() {
	echo -n "Defina el directorio de instalación de los ejecutables ($GRUPO/$BINDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de instalación de los ejecutables ($GRUPO/$BINDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$BINDIR"'-'`
	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done
	echo "$AUX"

	#Reservar este path en la variable BINDIR
	BINDIR=$AUX
	
	echo "$GRUPO/$BINDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$BINDIR"

}

# 8. Definir el directorio de instalación de los archivos Maestros
definirDirectorioMaestros() {
	echo -n "Defina el directorio de instalación de los archivos maestros ($GRUPO/$MAEDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de instalación de los archivos maestros ($GRUPO/$MAEDIR): "
        
	read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"mae"'-'`

	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done	

	#Reservar este path en la variable MAEDIR
	MAEDIR=$AUX

	echo "$GRUPO/$MAEDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$MAEDIR"
}

# 9. Definir el directorio de arribo de archivos externos
definirDirectorioArribos() {
	echo -n "Defina el directorio de arribo de archivos externos ($GRUPO/$ARRIDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de arribo de archivos externos ($GRUPO/$ARRIDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"arribos"'-'`

	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done

	ARRIDIR=$AUX
	echo "$GRUPO/$ARRIDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$ARRIDIR"
}

#10. Definir espacio minimo libre para el arribo de archivos
definirEspacioMinimoParaExternos() {
	echo -n "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (100):"
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (100):"

	esNumero=0
	numero='X'
	
	while [ $esNumero -ne 1 ]; do
	  read INPUT
  	  numero=`echo "$INPUT"` # mantengo el original en $numero y reviso que sea numerico usando la auxiliar $numero1
	  numero=`echo "$numero" | sed 's-^$-'"$DATASIZE"'-'` # si no ingresa nada se toma el default
	  numero1=`echo "$numero" | grep '^[0-9]*$' | sed 's-^$-'"$DATASIZE"'-'` 
	  numero1=`echo "$numero" | grep '^[0-9]*$'`
	  if [ -z $numero1 ]; then
	    esNumero=2
	    echo " \"$numero\" no es numerico. Intente Nuevamente"
	    ./Grabar_L.sh -i "Instalar_TP" -t i " \"$numero\" no es numerico. Intente Nuevamente"
	  else
	    esNumero=1
	  fi  
	done

	DATASIZE=$numero
	echo $DATASIZE
	./Grabar_L.sh -i "Instalar_TP" -t i "$DATASIZE"
}

# 11. Verificar espacio en disco
verificarEspacioEnDisco() {
	ESPACIO=`df -BM . | sed 's/ \+/,/g' | cut -f4 -d, | tail -1 | sed 's/M//'`
	
	if [ $ESPACIO -lt $DATASIZE ]
	then
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $ESPACIO Mb."
		echo "Espacio requerido $DATASIZE Mb"
		echo "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor."
		./Grabar_L.sh -i "Instalar_TP" -t i "Insuficiente espacio en disco."
		./Grabar_L.sh -i "Instalar_TP" -t i "Espacio disponible: $ESPACIO Mb."
		./Grabar_L.sh -i "Instalar_TP" -t i "Espacio requerido $DATASIZE Mb"
		./Grabar_L.sh -i "Instalar_TP" -t i "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor."

		definirEspacioMinimoParaExternos
	fi
}

# 12. Definir el directorio de aceptados
definirDirectorioArribosAceptados() {
	echo -n "Defina el directorio de grabación de los archivos externos aceptados ($GRUPO/$ACEPDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de grabación de los archivos externos aceptados ($GRUPO/$ACEPDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"aceptados"'-'`
	
	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done

	ACEPDIR=$AUX

	echo "$GRUPO/$ACEPDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$ACEPDIR"
}

# 13. Definir el directorio de rechazados
definirDirectorioArribosRechazados() {
	echo -n "Defina el directorio de grabación de los archivos externos rechazados ($GRUPO/$RECHDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de grabación de los archivos externos rechazados ($GRUPO/$RECHDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"rechazados"'-'`
	
	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done

	RECHDIR=$AUX

	echo "$GRUPO/$RECHDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$RECHDIR"
}

# 14. Definir el directorio de procesados
definirDirectorioProcesados() {
	echo -n "Defina el directorio de grabación de los archivos procesados ($GRUPO/$PROCDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de grabación de los archivos procesados ($GRUPO/$PROCDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"procesados"'-'`
		
	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done

	PROCDIR=$AUX

	echo "$GRUPO/$PROCDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$PROCDIR"
}

# 15. Definir el directorio de Listados
definirDirectorioListados() {
	echo -n "Defina el directorio de los listados de salida ($GRUPO/$REPODIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de los listados de salida ($GRUPO/$REPODIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"repo"'-'`
	
	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done

	REPODIR=$AUX
	echo "$GRUPO/$REPODIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$REPODIR"
}

#16. Definir el directorio de logs para los comandos
definirDirectorioLogs() {
	echo -n "Defina el directorio de logs ($GRUPO/$LOGDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de logs ($GRUPO/$LOGDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"log"'-'`
	
	aux=`auxValidaDirectorio "$AUX"`
	while [ "$aux" == "Invalido" ]; do
		echo "Directorio: $AUX es inválido. Ingrese nuevamente"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio: $AUX es inválido. Ingrese nuevamente"
		read AUX
		aux=`auxValidaDirectorio "$AUX"`
	done

	LOGDIR=$AUX

	echo "$GRUPO/$LOGDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "$GRUPO/$LOGDIR"
}

#17. Definir la extensión para los archivos de log
definirExtensionLogs() {
	echo -n "Ingrese la extensión para los archivos de log: ($LOGEXT): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Ingrese la extensión para los archivos de log: ($LOGEXT): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$LOGEXT"'-'`
	
	LOGEXT=$AUX
	echo $LOGEXT
	./Grabar_L.sh -i "Instalar_TP" -t i "$LOGEXT"
}

# 18. Definir tamaño maximo LOG
definirTamanioMaximoLog() {
	echo -n "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"


	esNumero=0
	numero='X'
	
	while [ $esNumero -ne 1 ]; do
	  read INPUT
  	  numero=`echo "$INPUT"` # mantengo el original en $numero y reviso que sea numerico usando la auxiliar $numero1
	  numero=`echo "$numero" | sed 's-^$-'"$LOGSIZE"'-'` # si no ingresa nada se toma el default
	  numero1=`echo "$numero" | grep '^[0-9]*$' | sed 's-^$-'"$LOGSIZE"'-'` 
	  numero1=`echo "$numero" | grep '^[0-9]*$'`
	  if [ -z $numero1 ]; then
	    esNumero=2
	    echo " \"$numero\" no es númerico. Intente nuevamente."
	    ./Grabar_L.sh -i "Instalar_TP" -t i " \"$numero\" no es númerico. Intente nuevamente."
	  else
	    esNumero=1
	  fi  
	done
	
	echo $numero
	
	LOGSIZE=$numero
	echo $LOGSIZE
	./Grabar_L.sh -i "Instalar_TP" -t i "$LOGSIZE"
}

# 19. Mostrar estructura de directorios resultante y valores de parámetros configurados
mostrarEstructura() {
	limpiarPantalla
	verEstructura

	echo "¿Los datos ingresados son válidos? (Si-No): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Los datos ingresados son válidos? (Si/No): "

	INPUT="0"
	while [ "$INPUT" != 'No' ] && [ "$INPUT" != 'Si' ]; do  # falla con cadena vacia
	    read INPUT
	    ./Grabar_L.sh -i "Instalar_TP" -t i "$INPUT"

	    AUX=`echo $INPUT | sed 's-^$-X-'`
	    if [ $AUX == 'No' ];
	    then
        	limpiarPantalla
		definirParametros
		mostrarEstructura
	    fi

	    INPUT=$AUX
	done
}

# 19.1. Limpiar Pantalla
limpiarPantalla() {
	clear
}

# 19.2 Ver estructura final
verEstructura() {
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01
	Librería del Sistema: $GRUPO/$CONFDIR
	Ejecutables: $GRUPO/$BINDIR
	Archivos maestros: $GRUPO/$MAEDIR
	Directorio de arribo de archivos externos: $GRUPO/$ARRIDIR
	Espacio mínimo libre para arribos: $DATASIZE Mb
	Archivos externos aceptados: $GRUPO/$ACEPDIR
	Archivos externos rechazados: $GRUPO/$RECHDIR
	Archivos procesados: $GRUPO/$PROCDIR
	Reportes de salida: $GRUPO/$REPODIR
	Logs de auditoria del Sistema: $GRUPO/$LOGDIR/<comando>.$LOGEXT
	Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb
	Estado de la instalacion: LISTA."
	./Grabar_L.sh -i "Instalar_TP" -t i "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
	./Grabar_L.sh -i "Instalar_TP" -t i "Librería del Sistema: $GRUPO/$CONFDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Ejecutables: $GRUPO/$BINDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos maestros: $GRUPO/$MAEDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Directorio de arribo de archivos externos: $GRUPO/$ARRIDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Espacio mínimo libre para arribos: $DATASIZE Mb"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos aceptados: $GRUPO/$ACEPDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos rechazados: $GRUPO/$RECHDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos procesados: $GRUPO/$PROCDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Reportes de salida: $GRUPO/$REPODIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Logs de auditoria del Sistema: $GRUPO/$LOGDIR/<comando>.$LOGEXT"
	./Grabar_L.sh -i "Instalar_TP" -t i "Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb"
	./Grabar_L.sh -i "Instalar_TP" -t i "Estado de la instalacion: LISTA"

}

# 20. Confirmar Inicio de Instalación
confirmarInicio() {
	echo "Iniciando Instalación. ¿Está seguro? (Si-No)"
	./Grabar_L.sh -i "Instalar_TP" -t i "Iniciando Instalación. ¿Está seguro? (Si-No)"

	INPUT="0"
	while [ "$INPUT" != 'No' ] && [ "$INPUT" != 'Si' ]; do  # falla con cadena vacia
	    read INPUT
	    ./Grabar_L.sh -i "Instalar_TP" -t i "$INPUT"

	    AUX=`echo $INPUT | sed 's-^$-X-'`
	    if [ $AUX == 'No' ];
	    then
		fin
	    fi
	    if [ $AUX == 'Si' ];
	    then
		instalacion
	    fi
	    INPUT=$AUX
	done
}

# 21. Instalación
instalacion() {
	crearEstructuras
	moverMaestros
	moverDisponibilidad
	moverProgramasYFunciones
	actualizarArchivoConfiguracion
}

# 21.1. Crear Estructuras
crearEstructuras() {
	echo "Creando Estructuras de directorio. . . ."
	./Grabar_L.sh -i "Instalar_TP" -t i "Creando Estructuras de directorio. . . ."
	mkdir -p "$GRUPO/$BINDIR"
	mkdir -p "$GRUPO/$MAEDIR"
	mkdir -p "$GRUPO/$ARRIDIR"
	mkdir -p "$GRUPO/$ACEPDIR"
	mkdir -p "$GRUPO/$RECHDIR"
	mkdir -p "$GRUPO/$PROCDIR"
	mkdir -p "$GRUPO/$REPODIR"
	mkdir -p "$GRUPO/$LOGDIR"
}

# 21.2. Mover los archivos maestros al directorio MAEDIR mostrando el siguiente mensaje
moverMaestros() {
	echo "Instalando archivos maestros."
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalando Archivos Maestros" 

	if [ -f "$OBRAS_FILE" ]; then
		if [ ! -f "$GRUPO/$MAEDIR/obras.mae" ]; then
			cp "$OBRAS_FILE" "$GRUPO/$MAEDIR"
		fi
	else
		echo "ERROR: No se encontró el archivo de Obras."
		echo "Verifique que la instalación tenga el archivo mae/obras.mae."
		./Grabar_L.sh -i "Instalar_TP" -t i "No se encontro el archivo de Obras"
		./Grabar_L.sh -i "Instalar_TP" -t i "Verifique que la instalación tenga el archivo mae/obras.mae"
		fin
	fi

	if [ -f "$SALAS_FILE" ]; then
		if [ ! -f "$GRUPO/$MAEDIR/salas.mae" ]; then
			cp "$SALAS_FILE" "$GRUPO/$MAEDIR"
		fi
	else
		echo "ERROR: No se encontró el archivo de Salas."
		echo "Verifique que la instalación tenga el archivo mae/salas.mae."
		./Grabar_L.sh -i "Instalar_TP" -t i "No se encontro el archivo de Salas"
		./Grabar_L.sh -i "Instalar_TP" -t i "Verifique que la instalación tenga el archivo mae/salas.mae"
		fin
	fi

}

# 21.3.Mover el archivo de disponibilidad al directorio PROCDIR mostrando el siguiente mensaje
moverDisponibilidad() {
	echo "Instalando archivo de disponibilidad."
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalando Archivo de Disponibilidad"

	if [ -f "$COMBOS_FILE" ]; then
		if [ ! -f "$GRUPO/$PROCDIR/combos.dis" ]; then
			cp "$COMBOS_FILE" "$GRUPO/$PROCDIR"
		fi
	else
		echo "ERROR: No se encontró el archivo de disponibilidad."
		echo "Verifique que la instalación tenga el archivo disp/combos.dis"
		./Grabar_L.sh -i "Instalar_TP" -t i "No se encontró el archivo de disponibilidad"
		./Grabar_L.sh -i "Instalar_TP" -t i "Verifique que la instalación tenga el archivo disp/combos.dis"
		fin
	fi
}

# 21.4. Mover los ejecutables y funciones al directorio BINDIR mostrando el siguiente mensaje
moverProgramasYFunciones() {
	echo "Instalando programas y funciones."
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalando Programas y Funciones"

	cp "./Iniciar_A.sh" "$GRUPO/$BINDIR/"
	cp "./Recibir_A.sh" "$GRUPO/$BINDIR/"
	cp "./Reservar_A.sh" "$GRUPO/$BINDIR/"
	cp "./Start_A.sh" "$GRUPO/$BINDIR/"
	cp "./Stop_A.sh" "$GRUPO/$BINDIR/"
	cp "./Mover_A.sh" "$GRUPO/$BINDIR/"
	cp "./Imprimir_A.pl" "$GRUPO/$BINDIR/"
	cp "./Grabar_L.sh" "$GRUPO/$BINDIR/"

	chmod +x "$GRUPO/$BINDIR/Iniciar_A.sh"	
	chmod +x "$GRUPO/$BINDIR/Recibir_A.sh"
	chmod +x "$GRUPO/$BINDIR/Reservar_A.sh"	
	chmod +x "$GRUPO/$BINDIR/Start_A.sh"	
	chmod +x "$GRUPO/$BINDIR/Stop_A.sh"	
	chmod +x "$GRUPO/$BINDIR/Mover_A.sh"
	chmod +x "$GRUPO/$BINDIR/Imprimir_A.pl"
	chmod +x "$GRUPO/$BINDIR/Grabar_L.sh"
}

# 21.5. Actualizar el archivo de configuración mostrando el siguiente mensaje
actualizarArchivoConfiguracion() {
	echo "Actualizando la configuración del sistema."
	./Grabar_L.sh -i "Instalar_TP" -t i "Actualizando la configuración del sistema."
	
	AM_PM=$(date +"%P")
	AM_PM=`echo $AM_PM | sed "s/\(.\)\(.\)/\1.\2/g"`

	fecha=$(date +"%d/%m/%Y %H:%M")
	fecha="$fecha $AM_PM"

	FECHA_AUX=$fecha
	LINEA_AUX="GRUPO=$GRUPO=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="CONFDIR=$CONFDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="BINDIR=$BINDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="MAEDIR=$MAEDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="ARRIDIR=$ARRIDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="DATASIZE=$DATASIZE=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="ACEPDIR=$ACEPDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="RECHDIR=$RECHDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="PROCDIR=$PROCDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="REPODIR=$REPODIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="LOGDIR=$LOGDIR=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	LINEA_AUX="LOGEXT=$LOGEXT=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp
	
	LINEA_AUX="LOGSIZE=$LOGSIZE=$USUARIO=$FECHA_AUX"
	echo "$LINEA_AUX" >> configuracion.conf.tmp

	cat configuracion.conf.tmp > "$GRUPO/$CONFDIR/Instalar_TP.conf"
	rm configuracion.conf.tmp

}

# 23. Instalacion Concluida
instalacionConcluida() {
	echo "Instalación CONCLUIDA"
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalación CONCLUIDA"
}

# 24. FIN
function fin() {
# CERRAR ARCHIVO DE LOG
    exit 0
}

definirParametros() {
	#7
	definirDirectorioEjecutables
	#8
	definirDirectorioMaestros
	#9
	definirDirectorioArribos
	#10
	definirEspacioMinimoParaExternos
	#11
	verificarEspacioEnDisco
	#12
	definirDirectorioArribosAceptados
	#13
	definirDirectorioArribosRechazados
	#14
	definirDirectorioProcesados
	#15
	definirDirectorioListados
	#16
	definirDirectorioLogs
	#17
	definirExtensionLogs
	#18
	definirTamanioMaximoLog
}

# se chequea que la version de bash sea 4 o mayor
chequearBash

# se guarda el nombre del usuario
USUARIO=$USER

# La variable grupo se completa con el directorio de trabajo
dir=$(readlink -f $0)
parentdir="$(dirname "$dir")"
GRUPO="`echo ${parentdir%/*}`"
export GRUPO


# Inicia variables por defecto
CONFDIR="conf"
export CONFDIR
LOGSIZE=400
export LOGSIZE
# se exportan para ser utilizadas por el LOG

# si no hay instalacion previa -> seteo las variables con valores default
if [ ! -f "$GRUPO/$CONFDIR/Instalar_TP.conf" ]; then
	BINDIR="bin"
	MAEDIR="mae" 
	ARRIDIR="arribos" 
	DATASIZE=100  
	ACEPDIR="aceptados" 
	RECHDIR="rechazados" 
	PROCDIR="proc" 
	REPODIR="repo" 
	LOGDIR="log" 
	LOGEXT="log"
else
# si hay una instalacion previa completo las variables con el contenido del archivo	
	GRUPO=`grep "^GRUPO=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	BINDIR=`grep "^BINDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	MAEDIR=`grep "^MAEDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	ARRIDIR=`grep "^ARRIDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`	
	DATASIZE=`grep "^DATASIZE=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`	
	ACEPDIR=`grep "^ACEPDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	RECHDIR=`grep "^RECHDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	PROCDIR=`grep "^PROCDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	REPODIR=`grep "^REPODIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	LOGDIR=`grep "^LOGDIR=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
	LOGEXT=`grep "^LOGEXT=.*$" "$GRUPO/$CONFDIR/Instalar_TP.conf" | sed "s~.*=\(.*\)=.*=.*$~\1~"`
fi

# Archivos maestros y de disponibilidad
#salas.mae
SALAS_FILE="../mae/salas.mae"
#obras.mae
OBRAS_FILE="../mae/obras.mae"
#combos.dis
COMBOS_FILE="../disp/combos.dis"

# se inician variables
iniciar_a_file=0
recibir_a_file=0
reservar_a_file=0
start_a_file=0
stop_a_file=0
mover_a_file=0
grabar_l_file=0
imprimir_a_file=0

# GENERO LA CARPETA DEL SISTEMA SI ES QUE NO EXISTE
 mkdir -p "$GRUPO/$CONFDIR"

#1
iniciarLogDeInstalacion
#2
mostrarUbicacionDelLogDeInstalacion
#3
mostrarDirectorioDeConfiguracion
#4
verificarInstalacionPrevia
#5
aceptarTerminosyCondiciones
#6
chequearPerl
#definirParametros pasos 7..18
definirParametros
#19
mostrarEstructura
#20
confirmarInicio
#21
#instalacion
#23
instalacionConcluida
#24
fin



