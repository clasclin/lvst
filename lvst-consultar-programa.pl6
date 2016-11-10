#!/usr/bin/env perl6
#
# lvst-consultar-programa.pl6 - Por defecto revisa cuál es el último archivo 
# y retorna la fecha del día siguiente, en cambio si se le pasa una fecha como
# argumento comprueba la existencia del mismo.
#

use v6;
use lib 'lib';
use Fechas;

sub MAIN(FechaVálida $fecha?) {

    my $dir-venganzas = "%*ENV<HOME>/Música/lvst/venganza";
    my $año;

    with $fecha {
        my $yyyy-mm-dd = convertir-fecha($fecha); 
        $año = Date.new($yyyy-mm-dd).year.Str;
        my $venganzas = join '', $dir-venganzas, $año;
        my $audio = join '/', $venganzas, "lavenganza_$yyyy-mm-dd.ogg";

        "$audio".IO.f
            ?? say "Existe" 
            !! say "No existe"; 
    }
     
    without $fecha {
        $año = Date.today.year().Str;
        my $venganzas = join '', $dir-venganzas, $año;

        if "$venganzas".IO.d {

            my @fechas;
            for dir($venganzas) -> $audio {
                my $fecha = $audio.basename.split('_')[1].split('.')[0];
                @fechas.push($fecha);
            }

            my $último-audio = @fechas.sort[*-1];
            my $última-fecha = Date.new($último-audio).later(:1day).Str;
            say $última-fecha;
        }
    }
}
