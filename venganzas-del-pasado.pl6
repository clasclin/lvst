#!/usr/bin/env perl6
#
# venganzas-del-pasado.pl6 - se encarga de generar urls para ser usadas por wget.
#

use v6;

subset FechaVálida of Str where * ~~ / \d**4 '-' \d**2 '-' \d**2 /; 

sub MAIN (FechaVálida $desde-fecha, $hasta-fecha = Date.today) { 

  constant URL = 'http://venganzasdelpasado.com.ar';

  my $fecha-inicial = Date.new($desde-fecha);
  my $fecha-final   = Date.new($hasta-fecha);

  if $fecha-inicial lt $fecha-final {
    until $fecha-inicial eq $fecha-final {
      my $año = $fecha-inicial.year;
      unless $fecha-inicial.day-of-week == 6|7 { # sábados y domingo no hay radio
        say (URL, $año, "lavenganza_$fecha-inicial.mp3").join('/');
      }
      $fecha-inicial .= later(:1day);
    }
  }
  else {
    say "$fecha-inicial no puede ser mayor que $fecha-final";
  }
}
