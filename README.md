# lvst (la venganza será terrible). 

El proyecto lvst contiene un script que descarga torrents del programa de
radio "La Venganza Será Terrible" 
'https://es.wikipedia.org/wiki/La_venganza_ser%C3%A1_terrible'.

El sitio desde el cual se descargan los audios es: 
'https://venganzasdelpasado.com.ar/' y pueden encontrar el proyecto que genera
la página en: 'https://github.com/jschwindt/Venganzas-del-Pasado'

# Descripción y uso del script.

La idea es básicamente tener un script que se ocupa de comprobar cual es el
último archivo en disco y de ser necesario generar un rango de enlaces de 
los torrents que faltan para ser descargados, luego se procede a descargar
los audios con el cliente torrent que se desee. Una vez descargados los audios
se usa un programa externo para convertir los audios a ogg.

Antes de empezar quiero aclarar que supociones hice:
 - se usa 'wget' para descargar los torrents
 - se usa 'dir2ogg' para convertir de mp3 a ogg
 - la estructura de directorios en la que se guardan los audios es por años

   venganzas/
   |
   |__ 2016
   |   |__ ...
   |   |__ ...
   |
   |__ 2017
       |__ lavenganza_2017-01-01.ogg

esto es así no por capricho sino por limitaciones o falta de experiencia de mi
parte. Por ahora no es sencillo reemplazar wget, dir2ogg, o la estructura de
directorios sin tener que cambiar el código del programa. También es de esperar
que el programa tenga errores.
 
## Uso

```
# la ayuda se obtiene con:

$ lvst --help
Usage:
  lvst.pl6 [--nono] 
  lvst.pl6 [--nono] <buscar-en> <guardar-en> 
  lvst.pl6 [--desde-fecha=<Str>] [--hasta-fecha=<Str>] [--descargar]

# con el argumento '[--nono]' genera el rango de fechas que faltan en disco
# y muestra los enlaces sin descargar los torrents
 
$ lvst --nono
...
wget http://s3.schwindt.org/dolina/AAAA/lavenganza_AAAA-MM-DD.mp3?torrent
...

# sin argumentos se encarga de generar el rango de fechas desde el último audio
# disponible en disco, se convierten los mp3 y se procede a descargar los torrents
# que faltan hasta el día de hoy

$ lvst
Nada por hacer

# con los argumentos opcionales '<buscar-en>' '<guardar-en>' se le indican los
# directorios en los cuales buscar los audios presentes y donde guardar los
# torrents.
 
$ lvst ~/Música/venganzas/ ~/Descargas/torrents/

# con los argumentos '[--desde-fecha]' '[--hasta-fecha]' puedo crear un rango 
# de días que faltan y me va a mostrar las urls de ese periodo de tiempo

$ lvst --desde-fecha=2016-12-31 --hasta-fecha=2017-01-05
http://s3.schwindt.org/dolina/2017/lavenganza_2017-01-02.mp3?torrent
http://s3.schwindt.org/dolina/2017/lavenganza_2017-01-03.mp3?torrent
http://s3.schwindt.org/dolina/2017/lavenganza_2017-01-04.mp3?torrent
```
