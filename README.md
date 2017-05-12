# lvst (la venganza será terrible). 

El proyecto lvst contiene un script que ayuda a la descarga del programa de
radio [La Venganza Será Terrible]
(https://es.wikipedia.org/wiki/La_venganza_ser%C3%A1_terrible).

El sitio desde el cual se descargan los audios es [venganzas del pasado] 
(https://venganzasdelpasado.com.ar/) y pueden encontrar el proyecto como
[venganzas-del-pasado](https://github.com/jschwindt/Venganzas-del-Pasado).

## Descripción y uso del script.

La idea es básicamente tener un script que se ocupa de comprobar cual es el
último archivo en disco y descarga los atchivos torrents que faltan o los audios
según se lo requiera. 

Parto de la siguiente estrucutura de directorios en la que se guardan los archivos:
```
  lvst/
  |
  |__ 2016
  |   |__ lavengaza_2016-01-01.ogg
  |   |__ ...
  |   |__ ...
  | 
  |__ 2017
      |__ lavenganza_2017-01-01.ogg
      |__ ...
      |__ ...
```
Mientras que los archivos descargados se guardan en:
```
  venganzas-del-pasado/
  |
  |__ dolina_2016_lavenganza_2016-01-01.mp3
  |__ ...
  |__ ...
```

## Ejemplos 

```bash
# la ayuda se obtiene con:

$ lvst --help
Usage:
  lvst [--nono] [--descarga-directa] [--no-filtrar] [--convertir-a-ogg]
  [<desde-fecha>] [<hasta-fecha>] 

# con el argumento '[--nono]' genera el rango de fechas que faltan en disco
# y muestra los enlaces sin descargar los torrents
 
$ lvst --nono
Descargando...
simulando: wget http://s3.schwindt.org/dolina/2017/lavenganza_2017-05-05.mp3?torrent
...

# sin argumentos se encarga de generar el rango de fechas desde el último audio
# disponible en disco y se procede a descargar los torrents que faltan hasta el
# día de hoy

$ lvst
Descargando...

# con el argumento '[--convertir-a-ogg]' convierte los mp3 que se encuentran 
# descargados y los copia. Se puede elegir a que directorios mediante el archivo
# de configuración

$ lvst --convertir-a-ogg
Convirtiendo a ogg...
Descargando...  

# con el argumento '[--no-filtrar]' se genera todo el rango a pesar de ya disponer
# de los archivos en disco. Omitiendo '[<hasta-fecha>]' asume que es el día de hoy

$ lvst --nono --no-filtrar 2017-03-01 2017-03-05 
Descargando...
simulando: wget http://s3.schwindt.org/dolina/2017/lavenganza_2017-03-01.mp3?torrent
simulando: wget http://s3.schwindt.org/dolina/2017/lavenganza_2017-03-02.mp3?torrent
simulando: wget http://s3.schwindt.org/dolina/2017/lavenganza_2017-03-03.mp3?torrent
```

## Requisitos

 - 'wget' se usa tanto para la descarga directa como para los archivos torrents
 - 'mpg123' para convertir los mp3 a wav
 - 'oggenc' para convertir los wav a ogg 
 - 'mp3-a-ogg.sh' tiene que ser visible desde $PATH

