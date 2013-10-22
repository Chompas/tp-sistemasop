Trabajo Práctico
===================
**Materia**: [75.08] Sistemas Operativos  
**Fecha**: Segundo Cuatrimestre de 2013  
**Grupo**: 1  
**Tema**: "A"  
**Integrantes**:  
   * Lucas Tarcetti  
   * Sergio Zelechowsky  
   * Maria Ines Parnisari  
   * Javier Lara  
   * Pablo Castarataro  
   * Emiliano Viscarra


Requisitos de instalación
--------------------
- Perl v5 o mayor. Si no lo tiene instalado, 
ejecute el siguiente comando:  `sudo apt-get install perl`


Cómo copiar desde un medio externo
--------------------
1. Insertar el dispositivo de almacenamiento que contiene el trabajo práctico.
2. Crear un directorio donde se desea copiar el contenido del trabajo práctico:  
`mkdir tp2013g1`
3. Copiar el archivo `.tgz` en el directorio recién creado:  
`cp /media/<NOMBRE_PENDRIVE>/<NOMBRE_ARCHIVO>.tgz tp2013g1`
4. Descomprimir y extrar el archivo `.tgz`:  
`tar -zxf <NOMBRE_ARCHIVO>.tgz`


Instalación
--------------------
1. Navegar hasta la carpeta donde se encuentran las funciones:  
`cd funciones`
2. Darle permisos de ejecución al script `Instalar_TP.sh`:  
`chmod +x Instalar_TP.sh`
3. Ejecutar el script pasando como parámetro la ruta donde se desee realizar las instalación:  
`./Instalar_TP.sh`
4. Seguir los pasos indicados.


Estructura post instalación
--------------------
Luego de la instalación se creará la siguiente estructura dentro de la carpeta donde instalamos
(en este ejemplo, `instalacion1`).
   `-> aceptados  
	-> arribos  
	-> bin  
		-> Grabar_L.sh  
		-> Iniciar_A.sh  
		-> Recibir_A.sh  
		-> Imprimir_A.pl  
		-> Mover_A.sh  
		-> Reservar_A.sh  
		-> Start_A.sh  
		-> Stop_A.sh  
	-> conf  
		-> Instalar_TP.conf  
    -> disp  
    -> funciones  
    -> log  
	-> mae  
		-> obras.mae  
		-> salas.mae  
	-> procesados  
		-> combos.dis  
	-> rechazados  
	-> repo  
`

Los nombres de las carpetas pueden variar según lo que ingrese el usuario. 
Estos valores son los valores por defecto de la instalación.

Además en la carpeta `tp2013g1` hay una carpeta `conf` donde está el log del instalador.


Primeros pasos
--------------------
1. Ir al directorio de instalación de los ejecutables `bin`.
2. Ejecutar el comando `. ./Iniciar_A.sh`.
3. Correr el demonio eligiendo `Si` al final de la ejecución del `Iniciar_A`,  
o corriendo `Start_A.sh`.
