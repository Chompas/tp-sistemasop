README.TXT
_______________________________
GRUPO 1 - TEMA A
SISTEMAS OPERATIVOS 75.08
FIUBA
-------------------------------

a. Copiar desde medio externo
	1. Insertar el dispositivo de almacenamiento que contiene el trabajo práctico
	2. Crear un directorio donde se desea copiar el contenido del trabajo práctico.
		> mkdir tp2013g1
	3. Copiar el archivo .tgz en el directorio recien creado.
		> cp /media/<NOMBRE_PENDRIVE>/<NOMBRE_ARCHIVO>.tgz tp2013g1
	4. Descomprimir el archivo .tgz para convertirlo en un .tar
		> 
	5. Extraer los archivos del .tar en la carpeta.
		> 

b. Una vez completados los pasos de "a." ya estamos en condiciones de instalar el aplicativo.
	1. Navegamos hasta la carpeta donde se encuentran las funciones.
		> cd funciones
	2. Le damos permisos de ejecución al script Instalar_TP.sh.
		> chmod +x Instalar_TP.sh
	3. Ejecutamos el script pasando como parámetro la ruta donde deseamos realizar las instalación.
		> ./Instalar_TP.sh instalacion1
	4. Completamos todos los pasos que se nos presentan en el Wizard. La serie de pasos dependerá de si se encuantra una antigua instalación o no.

c. Para la instalación es requisito indispensable tener una instalación de Perl v5 o mayor. Luego de la instalación se creará la siguiente estructura dentro de la carpeta donde instalamos (instalacion1 en este ejemplo).

-> instalacion1
	-> aceptados
	-> arribos
	-> bin
		-> Grabar_L.sh
		-> Iniciar_A.sh
		-> Recibir_A.sh
		-> Imprimir_A.pl  
		-> Mover_A.sh    
		-> Reservar_A.sh
		-> Start.sh
		-> Stop.sh
	-> conf
		-> Instalar_TP.conf
	-> log 
	-> mae
		-> obras.mae
		-> salas.mae
	-> procesados
		-> combos.dis
	-> rechazados  
	-> repo

Los nombres de las carpetas pueden variar según lo que ingrese el usuario. Estos valores son los valores por defecto de la instalación.

Además en la carpeta tp2013g1 hay una carpeta conf donde esta el log del instalador.

d. Primeros pasos.
	1. Ejecutar el comando Iniciar_A.sh
	2.

e. Comprobaciones.


f. Frenar ejecución de comandos.

