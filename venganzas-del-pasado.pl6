#!/usr/bin/env perl6
#
# venganzas-del-pasado.pl6 - por defecto genera enlaces para descarga directa,  
# aunque mediante un argumento se le puede pedir que genere enlaces de los
# archivos torrents. 
#

use v6;

my token amd { ^  \d**4  '-'  \d**2  '-'  \d**2  $ }; # AAAA-MM-DD
my token dma { ^ (\d**2) '-' (\d**2) '-' (\d**4) $ }; # DD-MM-AAAA
my token fecha { <amd> || <dma> || <ult> };           # AAAA-MM-DD o DD-MM-AAAA 

subset FechaVálida of Str where * ~~ / <fecha> /; 


sub MAIN(FechaVálida $desde-fecha, $hasta-fecha = Date.today, Bool :$torrents) { 

    my $fecha-inicial = $desde-fecha;
    my $fecha-final   = $hasta-fecha;

    for $fecha-inicial, $fecha-final { 
        if $_ ~~ / <dma> / { s/ <dma> /$<dma>[2]-$<dma>[1]-$<dma>[0]/ }
    } 

    $fecha-inicial = Date.new($fecha-inicial);
    $fecha-final   = Date.new($fecha-final);
 
    if $fecha-inicial lt $fecha-final {
        until $fecha-inicial eq $fecha-final {
            my $año = $fecha-inicial.year;
            unless $fecha-inicial.day-of-week == 6|7 { # sábados y domingo no hay programa 
                if $torrents {
                    state $url = 'http://s3.schwindt.org/dolina';
                    say ($url, $año, "lavenganza_$fecha-inicial.mp3?torrent").join('/');
                }
                else {
                    state $url = 'http://venganzasdelpasado.com.ar';
                    say ($url, $año, "lavenganza_$fecha-inicial.mp3").join('/');
                }
            }
            $fecha-inicial .= later(:1day);
        }
    }
    else {
        say "$fecha-inicial no debería ser mayor o igual a $fecha-final";
    }
}
