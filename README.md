# venganzas del pasado.

Scripts que descargan archivos de audios del programa de radio "La Venganza Será Terrible".
Ya sea descarga directa o bien se le puede pedir los enlaces torrents.
El sitio desde el cual se descargan los audios es: https://venganzasdelpasado.com.ar/ y
pueden encontrar el proyecto en: https://github.com/jschwindt/Venganzas-del-Pasado

La idea es básicamente la siguiente: tengo un script principal que se ocupa de comprobar 
cual es el último archivo en disco y de ser necesario generar un rango de enlaces de los
torrents que faltan, descarga los torrents y los convierte a un formato abierto como es ogg.

En lugar de tener un solo programa que se ocupe de todo preferí tener varios que cumplan
determinadas tareas porque es probable que más adelante quiera añadir algo y sería algo
complejo de mantener.

Si bien los nombres puede que cambien espero que las tareas de las que se ocupan cada una
de los programas no lo haga tanto.

## lvst-descargar.pl6

Es el programa principal, el encargado de juntar las partes para descargar los torrents
faltantes.

### Uso

```
# sin argumentos descarga los torretns que faltan
$ lvst-descargar.pl6

# con el argumento '[--simular]' muestra los comandos empleados en la descarga
$ lvst-descargar.pl6 --simular
...
wget http://s3.schwindt.org/dolina/AAAA/lavenganza_AAAA-MM-DD.mp3?torrent
...

# con el argumento '[<ruta>]' se indica el directorio a usar para las descargas
$ lvst-descargar.pl6 ~/venganza_torrents
```

## lvst-consultar-programa.pl6

Se ocupa dos tareas, bien puede entregar el día posterior al último archivo en disco o bien
comprueba la existencia.

### Uso

```
# sin argumentos devuelve la fecha posterior al último programa
$ lvst-consultar-programa.pl6
AAAA-MM-DD

# con el argumento '[<fecha>]' indica 'Existe' o 'No existe'
$ lvst-consultar-programa.pl6 AAAA-MM-DD
No existe
```
 
## venganzas-del-pasado.pl6

Se ocupa de generar los enlaces propiamente dichos, se puede usar solo como se indica
más abajo o en conjunto con el ya mencionado 'lvst-descargar.pl6'

### Uso

El programa permite que se le pasen dos fechas, la primera es obligatoria, mientras que
la segunda se puede omitir, en ese caso la segunda fecha queda establecida como hoy.
El formato usado para las fechas puede ser AAAA-MM-DD o bien DD-MM-AAAA.

```
$ venganzas-del-pasado.pl6 AAAA-MM-DD AAAA-MM-DD

# si son pocos audios se puede usar
$ venganzas-del-pasado.pl6 AAAA-MM-DD | wget --limit-rate 90k -i -

# si el rango de fechas es amplio tal vez convenga
for mp3 in $(venganzas-del-pasado.pl6 AAAA-MM-DD); do
    sleep 2
    wget --limit-rate 90k "$mp3"
done

# otra opción es simplemente guardar en un archivo para luego realizar la descarga
$ venganzas-del-pasado.pl6 AAAA-MM-DD > venganzas-mp3.txt 

# para los torrents simplemente añadir --torrents antes de indicar las fechas 
$ venganzas-del-pasado.pl6 --torrents DD-MM-AAAA
```
