#!/bin/bash

if [ "$#" -ne 1 ]
then
	echo "Cantidad de parámetros inválida"
	echo "Modo de uso:"
	echo "./Instalar_TP.sh \"path/grupo/\""
	exit 1
fi

USUARIO=$USER
GRUPO=$1

# Inicia variables por defecto
CONFDIR="conf"
export CONFDIR

BINDIR="/bin"
MAEDIR="/mae" 
ARRIDIR="/arribos" 
DATASIZE=100  
ACEPDIR="/aceptados" 
RECHDIR="/rechazados" 
PROCDIR="/proc" 
REPODIR="/repo" 
LOGDIR="/log" 
LOGEXT="log"
LOGSIZE=400
export LOGSIZE

iniciar_a_file=0
recibir_a_file=0
reservar_a_file=0
start_a_file=0
stop_a_file=0
mover_a_file=0
grabar_l_file=0
imprimir_a_file=0

# GENERO LA CARPETA DEL SISTEMA SI ES QUE NO EXISTE
 mkdir -p "$CONFDIR"
 mkdir -p "$GRUPO/$CONFDIR"

# Funciones auxiliares
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
		elif [ "Imprimir_A.sh" = "$componente" ]
		then
			imprimir_a_file=1
		elif [ "Grabar_L.sh" = "$componente" ]
		then
			grabar_l_file=1
		fi
    done

	if [ $iniciar_a_file -eq 1 ] && [ $recibir_a_file -eq 1] && [ $reservar_a_file -eq 1] && [ $start_a_file -eq 1 ] && [ $stop_a_file -eq 1 ] && [ $mover_a_file -eq 1 ] && [ $imprimir_a_file -eq 1 ] && [ $grabar_l_file -eq 1] 
	then
		echo "Estado de la instalación: COMPLETA"
		./Grabar_L.sh -i "Instalar_TP" -t i "Estado de la instalación: COMPLETA"

		echo "Proceso de Instalación Cancelado"
		./Grabar_L.sh -i "Instalar_TP" -t i "Proceso de Instalación Cancelado"
	else
		echo "Componentes faltantes:"
		./Grabar_L.sh -i "Instalar_TP" -t i "Componentes faltantes:"

		imprimirComponentesFaltantes
		echo "Estado de la instalación: INCOMPLETA"
		./Grabar_L.sh -i "Instalar_TP" -t i "Estado de la instalación: INCOMPLETA"

		echo "Desea completar la instalación? (Si-No)"
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

		# comprobar que esten las faltantes en alguna parte
		# si no estan --> ERROR
		# 

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
		echo "Imprimir_A.sh"
		./Grabar_L.sh -i "Instalar_TP" -t i "Imprimir_A.sh"
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
		
		ls $GRUPO/$CONFDIR
		./Grabar_L.sh -i "Instalar_TP" -t i "`ls $GRUPO/$CONFDIR`"

		echo "Ejecutables: $GRUPO$BINDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Ejecutables: $GRUPO$BINDIR"

		ls $GRUPO$BINDIR
		./Grabar_L.sh -i "Instalar_TP" -t i "`ls $GRUPO$BINDIR`"

		echo "Archivos Maestros: $GRUPO$MAEDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos Maestros: $GRUPO$MAEDIR"

		ls $GRUPO$MAEDIR
		./Grabar_L.sh -i "Instalar_TP" -t i "`ls $GRUPO$MAEDIR`"

		echo "Directorio de arribo de archivos externos: $GRUPO$ARRIDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Directorio de arribo de archivos externos: $GRUPO$ARRIDIR"

		echo "Archivos externos aceptados: $GRUPO$ACEPDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos aceptados: $GRUPO$ACEPDIR"

		echo "Archivos externos rechazados: $GRUPO$RECHDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos rechazados: $GRUPO$RECHDIR"

		echo "Reportes de salida: $GRUPO$REPODIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Reportes de salida: $GRUPO$REPODIR"

		echo "Archivos procesados: $GRUPO$PROCDIR"
		./Grabar_L.sh -i "Instalar_TP" -t i "Archivos procesados: $GRUPO$PROCDIR"

		echo "Logs de auditoria del Sistema: $GRUPO$LOGDIR/<comando>.$LOGEXT"
		./Grabar_L.sh -i "Instalar_TP" -t i "Logs de auditoria del Sistema: $GRUPO$LOGDIR/<comando>.$LOGEXT"

		verificarExistenciaComponentes
	    fin
	fi
}

# 5. Aceptar terminos y Condiciones
aceptarTerminosyCondiciones() {
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01
A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa 
aceptar los términos y Condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" 
incluido en este paquete.
Acepta? Si – No"
	./Grabar_L.sh -i "Instalar_TP" -t i "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
	./Grabar_L.sh -i "Instalar_TP" -t i "A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 UD. expresa
aceptar los términos y Condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete."
	./Grabar_L.sh -i "Instalar_TP" -t i "Acepta? Si – No"

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
Proceso de Instalación Cancelado"

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
	echo -n "Defina el directorio de instalación de los ejecutables ($GRUPO$BINDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de instalación de los ejecutables ($GRUPO$BINDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/bin"'-'`
	
	#Reservar este path en la variable BINDIR
	BINDIR=$AUX
	
	echo $BINDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$BINDIR"

}

# 8. Definir el directorio de instalación de los archivos Maestros
definirDirectorioMaestros() {
	echo -n "Defina el directorio de instalación de los archivos maestros ($GRUPO$MAEDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de instalación de los archivos maestros ($GRUPO$MAEDIR): "
        
	read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/mae"'-'`
	
	#Reservar este path en la variable MAEDIR
	MAEDIR=$AUX

	echo $MAEDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$MAEDIR"
}

# 9. Definir el directorio de arribo de archivos externos
definirDirectorioArribos() {
	echo -n "Defina el directorio de arribo de archivos externos ($GRUPO$ARRIDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de arribo de archivos externos ($GRUPO$ARRIDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/arribos"'-'`

	ARRIDIR=$AUX
	echo $ARRIDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$ARRIDIR"
}

#10. Definir espacio minimo libre para el arribo de archivos
definirEspacioMinimoParaExternos() {
	echo -n "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (100):"
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el espacio mínimo libre para el arribo de archivos externos en Mbytes (100):"

	read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$DATASIZE"'-' | grep '^[0-9]*$' | sed 's-^$-'"X"'-'`
	if [ AUX == "X" ];
	then
		definirEspacioMinimoParaExternos
	fi
#	AUX=`echo $AUX | grep '^[0-9]*$'`
	
	DATASIZE=$AUX
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
	echo -n "Defina el directorio de grabación de los archivos externos aceptados ($GRUPO$ACEPDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de grabación de los archivos externos aceptados ($GRUPO$ACEPDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/aceptados"'-'`
	
	ACEPDIR=$AUX

	echo $ACEPDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$ACEPDIR"
}

# 13. Definir el directorio de rechazados
definirDirectorioArribosRechazados() {
	echo -n "Defina el directorio de grabación de los archivos externos rechazados ($GRUPO$RECHDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de grabación de los archivos externos rechazados ($GRUPO$RECHDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/rechazados"'-'`
	
	RECHDIR=$AUX

	echo $RECHDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$RECHDIR"
}

# 14. Definir el directorio de procesados
definirDirectorioProcesados() {
	echo -n "Defina el directorio de grabación de los archivos procesados ($GRUPO$PROCDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de grabación de los archivos procesados ($GRUPO$PROCDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/procesados"'-'`
	
	PROCDIR=$AUX

	echo $PROCDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$PROCDIR"
}

# 15. Definir el directorio de Listados
definirDirectorioListados() {
	echo -n "Defina el directorio de los listados de salida ($GRUPO$REPODIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de los listados de salida ($GRUPO$REPODIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO/repo"'-'`
	
	REPODIR=$AUX
	echo $REPODIR
}

#16. Definir el directorio de logs para los comandos
definirDirectorioLogs() {
	echo -n "Defina el directorio de logs ($GRUPO$LOGDIR): "
	./Grabar_L.sh -i "Instalar_TP" -t i "Defina el directorio de logs ($GRUPO$LOGDIR): "

        read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$GRUPO$LOGDIR"'-'`
	
	LOGDIR=$AUX

	echo $LOGDIR
	./Grabar_L.sh -i "Instalar_TP" -t i "$LOGDIR"
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

	read INPUT
	# Si no ingresa nada se toma el valor por default
	AUX=`echo $INPUT | sed 's-^$-'"$LOGSIZE"'-' | grep '^[0-9]*$' | sed 's-^$-'"X"'-'`
	if [ AUX == "X" ];
	then
		definirTamanioMaximoLog
	fi
#	AUX=`echo $AUX | grep '^[0-9]*$'`
	
	LOGSIZE=$AUX
	echo $LOGSIZE
	./Grabar_L.sh -i "Instalar_TP" -t i "$LOGSIZE"
}

# 19. Mostrar estructura de directorios resultante y valores de parámetros configurados
mostrarEstructura() {
	limpiarPantalla
	verEstructura

	echo "Los datos ingresados son válidos? (Si/No): "
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
	Ejecutables: $BINDIR
	Archivos maestros: $MAEDIR
	Directorio de arribo de archivos externos: $ARRIDIR
	Espacio mínimo libre para arribos: $DATASIZE Mb
	Archivos externos aceptados: $ACEPDIR
	Archivos externos rechazados: $RECHDIR
	Archivos procesados: $PROCDIR
	Reportes de salida: $REPODIR
	Logs de auditoria del Sistema: $LOGDIR/<comando>.$LOGEXT
	Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb
	Estado de la instalacion: LISTA"
	./Grabar_L.sh -i "Instalar_TP" -t i "TP SO7508 Segundo Cuatrimestre 2013. Tema A Copyright © Grupo 01"
	./Grabar_L.sh -i "Instalar_TP" -t i "Librería del Sistema: $GRUPO/$CONFDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Ejecutables: $BINDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos maestros: $MAEDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Directorio de arribo de archivos externos: $ARRIDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Espacio mínimo libre para arribos: $DATASIZE Mb"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos aceptados: $ACEPDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos externos rechazados: $RECHDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Archivos procesados: $PROCDIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Reportes de salida: $REPODIR"
	./Grabar_L.sh -i "Instalar_TP" -t i "Logs de auditoria del Sistema: $LOGDIR/<comando>.$LOGEXT"
	./Grabar_L.sh -i "Instalar_TP" -t i "Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb"
	./Grabar_L.sh -i "Instalar_TP" -t i "Estado de la instalacion: LISTA"

}

# 20. Confirmar Inicio de Instalación
confirmarInicio() {
	echo "Iniciando Instalación. Esta Ud. seguro? (Si-No)"
	./Grabar_L.sh -i "Instalar_TP" -t i "Iniciando Instalación. Esta Ud. seguro? (Si-No)"

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
	mkdir -p $BINDIR
	mkdir -p $MAEDIR
	mkdir -p $ARRIDIR
	mkdir -p $ACEPDIR
	mkdir -p $RECHDIR
	mkdir -p $PROCDIR
	mkdir -p $REPODIR
	mkdir -p $LOGDIR
}

# 21.2. Mover los archivos maestros al directorio MAEDIR mostrando el siguiente mensaje
moverMaestros() {
	echo "Instalando Archivos Maestros"
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalando Archivos Maestros" 
	# mover
}

# 21.3.Mover el archivo de disponibilidad al directorio PROCDIR mostrando el siguiente mensaje
moverDisponibilidad() {
	echo "Instalando Archivo de Disponibilidad"
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalando Archivo de Disponibilidad"
	# mover
}

# 21.4. Mover los ejecutables y funciones al directorio BINDIR mostrando el siguiente mensaje
moverProgramasYFunciones() {
	echo "Instalando Programas y Funciones"
	./Grabar_L.sh -i "Instalar_TP" -t i "Instalando Programas y Funciones"

	cp "./Iniciar_A.sh" "$BINDIR/"
	cp "./Recibir_A.sh" "$BINDIR/"
	cp "./Reservar_A.sh" "$BINDIR/"
	cp "./Start_A.sh" "$BINDIR/"
	cp "./Stop_A.sh" "$BINDIR/"
	cp "./Mover_A.sh" "$BINDIR/"
	cp "./Imprimir_A.sh" "$BINDIR/"
	cp "./Grabar_L.sh" "$BINDIR/"
}

# 21.5. Actualizar el archivo de configuración mostrando el siguiente mensaje
actualizarArchivoConfiguracion() {
	echo "Actualizando la configuración del sistema"
	./Grabar_L.sh -i "Instalar_TP" -t i "Actualizando la configuración del sistema"
	
	fecha=$(date +"%d/%m/%y %T") #FIXME: ARREGLAR FORMATO DE LA FECHA Y REEMPLAZAR FECHA_AUX

	FECHA_AUX="30/09/2013 10:03 p.m"
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
