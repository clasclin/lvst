#!/usr/bin/env perl6
#
# lvst-consultar-programa.pl6 - Por defecto revisa cuál es el último archivo 
# y retorna la fecha del día siguiente, en cambio si se le pasa una fecha como
# argumento comprueba la existencia del mismo.
#

use v6;


sub MAIN($fecha?) {

    my $año;
    with $fecha {
        $año = Date.new($fecha).year.Str;
        my $venganzas = "%*ENV<HOME>/Música/lvst/venganza{$año}";
        my $audio = join '/', $venganzas, "lavenganza_$fecha.ogg";

        "$audio".IO.f
            ?? say "Existe" 
            !! say "No existe"; 
    }
     
    without $fecha {
        $año = Date.today.year().Str;

        my $venganzas = "%*ENV<HOME>/Música/lvst/venganza{$año}";

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
