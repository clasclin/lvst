# venganzas del pasado.

Script que genera enlaces de archivos de audios del programa de radio "La Venganza Será Terrible".
Ya sea descarga directa o bien se le puede pedir los enlaces torrents.
El sitio desde el cual se descargan los audios es: https://venganzasdelpasado.com.ar/ y
pueden encontrar el proyecto en: https://github.com/jschwindt/Venganzas-del-Pasado

## Uso

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
