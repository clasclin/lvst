#!/usr/bin/env perl6
#
# venganzas-del-pasado.pl6 - por defecto genera enlaces para descarga directa,  
# aunque mediante un argumento se le puede pedir que genere enlaces de los
# archivos torrents. 
#

use v6;

subset FechaVálida of Str where * ~~ / \d**4 '-' \d**2 '-' \d**2 /; 

sub MAIN (FechaVálida $desde-fecha, $hasta-fecha = Date.today, Bool :$torrents) { 

  my $fecha-inicial = Date.new($desde-fecha);
  my $fecha-final   = Date.new($hasta-fecha);

  if $fecha-inicial lt $fecha-final {
    until $fecha-inicial eq $fecha-final {
      my $año = $fecha-inicial.year;
      unless $fecha-inicial.day-of-week == 6|7 { # sábados y domingo no hay radio
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
    say "$fecha-inicial no puede ser mayor que $fecha-final";
  }
}
