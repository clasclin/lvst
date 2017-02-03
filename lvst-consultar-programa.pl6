#!/usr/bin/env perl6
#
# lvst-consultar-programa.pl6 - Por defecto revisa cuál es el último archivo
# y retorna la fecha del día siguiente, en cambio si se le pasa una fecha como
# argumento comprueba la existencia del archivo en disco.
#

use v6;
use Fechas;


my Str $año        = Date.today.year.Str;
my Str $dir-audios = "$*HOME/Música/lvst/$año";


multi MAIN (FechaVálida $fecha!) {
    # dada una fecha comprueba la existencia del archivo en disco

    my Str $día-mes-año = convertir-fecha($fecha);
    my Str $año         = $día-mes-año.split('-')[0];
    my Str $venganzas   = join '', $dir-audios, $año;
    my Str $audio       = join '/', $venganzas, "lavenganza_$día-mes-año.ogg";

    $audio.IO.f
        ?? say "Existe"
        !! say "No existe";
}


multi MAIN (Str $buscar-en = $dir-audios) {
    # sin fecha busca el último archivo en disco 

    if $buscar-en.IO.d {
        my Str $último-audio = dir($buscar-en, test => / '.ogg' $ /)>>.basename.sort.tail;
        say $último-audio.split('_')[1].split('.')[0].succ if $último-audio;
    }
    else {
        die "$buscar-en no existe";
    }
}
