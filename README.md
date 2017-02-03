# lvst (la venganza será terrible). 

lvst contiene una serie de scripts que descargan archivos de audios del programa
de radio "La Venganza Será Terrible". Tanto la descarga directa (requiere wget)
o bien se le puede pedir los enlaces torrents.

El sitio desde el cual se descargan los audios es: 
'https://venganzasdelpasado.com.ar/' y pueden encontrar el proyecto que genera
la página en: 'https://github.com/jschwindt/Venganzas-del-Pasado'

La idea es básicamente tener un script principal que se ocupa de comprobar cual
es el último archivo en disco y de ser necesario generar un rango de enlaces de 
los torrents que faltan, luego descargarlos y en un futuro pasarlos a un formato
abierto como es ogg.

En lugar de tener un solo programa que se ocupe de todo preferí tener varios que
cumplan determinadas tareas, debido a esto puede que existan ciertas redundancias
innecesarias o variables duplicadas.

# Descripción y uso de los scripts.

## lvst.pl6

Es el programa principal, el encargado de juntar las partes para descargar los
torrents faltantes. En caso de ser la primera vez en descargar archivos convien
ver como utilizar 'venganzas-del-pasado.pl6'

### Uso

```
# la ayuda se obtiene con:
$ lvst.pl6 --help
Usage:
  lvst.pl6 [--nono] [<guardar-en>] [<buscar-en>]

# con el argumento '[--nono]' muestra los comandos empleados en la descarga.
$ lvst.pl6 --nono
...
wget http://s3.schwindt.org/dolina/AAAA/lavenganza_AAAA-MM-DD.mp3?torrent
...

# con el argumento '[<guardar-en>]' se le indica el lugar donde se quieren
# almacenar los torrents.
$ lvst.pl6 ~/Descargas/torrents

# con el argumento '[<buscar-en>]' se le indica el directorio el cual ya
# contiene audios anteriores.
$ lvst.pl6 <guardar-en> ~/Música/lvst 

# lo más sencillo sería modificar las variables ($descargas, $dir-audios) en
# el propio código para que apunten a los directorios correspondientes
```

## lvst-copiar-mp3.pl6

Se ocupa de renombrar los archivos descargados desde origen y copiarlos al 
destino ($org, $dst) siempre y cuando no exista el audio.

### Uso

```
# ayuda 
$ lvst-copiar-mp3.pl6 --help
Usage:
  lvst-copiar-mp3.pl6 [--quitar=<Any>] <archivo>
  lvst-copiar-mp3.pl6 [--quitar=<Any>] [--nono]

# el argumento '<archivo>' es obligatorio y está pensado para ser usado por 
# por el cliente bittorrent.
$ lvst-copiar-mp3.pl6 dolina_AAA_lavenganza_AAA-MM-DD.mp3

# el argumento '[--quitar]' permite modificar la parte que tiene que eliminar
# del audio, por defecto se elimina 'dolina_AAA_'
# audio descargado de torrent: 'dolina_AAA_lavenganza_AAA-MM-DD.mp3'
# audio renombrado: 'lavenganza_AAA-MM-DD.mp3'
$ lvst-copiar-mp3.pl6 --quitar='dolina_' <archivo>

# el argumento '[--nono]' es opcional y simula el copiar y pegar 
$ lvst-copiar-mp3.pl6 --nono <archivo>
```

## lvst-consultar-programa.pl6

Se ocupa de dos tareas, bien puede entregar el día posterior al último archivo
en disco o bien comprueba la existencia de dicho archivo.

### Uso

```
# la ayuda indica que hay dos maneras posibles de llamarlo: bien sea con una 
# fecha obligatoria o bien se le puede indicar en donde buscar (véase <buscar-en>
# del ejemplo anterior).
$ lvst-consultar-programa.pl6 --help
Usage:
  lvst-consultar-programa.pl6 <fecha>
  lvst-consultar-programa.pl6 [<buscar-en>]

# sin argumentos devuelve la fecha posterior al último programa
$ lvst-consultar-programa.pl6
AAAA-MM-DD

# con el argumento '<fecha>' indica 'Existe' o 'No existe'
$ lvst-consultar-programa.pl6 AAAA-MM-DD
No existe
```
 
## venganzas-del-pasado.pl6

Se ocupa de generar los enlaces (torrents o descarga directa) según se lo requiera. 
El programa permite que se le pasen dos fechas, la primera es obligatoria, mientras
que la segunda se puede omitir, en ese caso la segunda fecha queda establecida como
hoy. El formato usado para las fechas puede ser AAAA-MM-DD o bien DD-MM-AAAA.

### Uso.

```
# la ayuda:
$ venganzas-del-pasado.pl6 --help 
Usage:
  venganzas-del-pasado.pl6 [--torrents] <desde-fecha> [<hasta-fecha>] 

# el argumento '<desde-fecha>' es obligatorio.
$ venganzas-del-pasado.pl6 AAA-MM-DD

# opcionalmente se puede pasar '<hasta-fecha>'.
$ venganzas-del-pasado.pl6 AAAA-MM-DD AAAA-MM-DD

# con el argumento '[--torrents]' genera los enlaces para descargar torrents.
$ venganzas-del-pasado.pl6 --torrents <desde-fecha> <hasta-fecha>

# si son pocos audios se puede usar
$ venganzas-del-pasado.pl6 AAAA-MM-DD | wget --limit-rate 90k -i -

# si el rango de fechas es amplio tal vez convenga
for mp3 in $(venganzas-del-pasado.pl6 AAAA-MM-DD)
do
  sleep 2;
  wget --limit-rate 90k "$mp3";
done

# otra opción es simplemente guardar en un archivo para luego realizar la descarga
$ venganzas-del-pasado.pl6 AAAA-MM-DD > venganzas-mp3.txt 
```
