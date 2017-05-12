#!/usr/bin/env perl6
#
#------------------------------------------------------------------------------
# clasclin (2017) - MIT
#
# lvst - Descarga venganzas del pasado 
#
#    Uso:
#
#        lvst --nono      # muestra cuales enlaces va a descargar
#        lvst 2017-04-02  # genera un rango de fechas omitiendo los que ya tenga
#
#-------------------------------------------------------------------------------


use v6;
use lib 'lib';
use LVST;


sub MAIN (
        Str $desde-fecha?,
        Str $hasta-fecha?,
        Bool :$nono,
        Bool :$descarga-directa,
        Bool :$no-filtrar,
        Bool :$convertir-a-ogg
    ) {

    my $venganzas = LVST::Venganzas.new;

    my $desde =  $desde-fecha
              ?? Date.new($desde-fecha)
              !! $venganzas.último-programa; 

    my $hasta =  $hasta-fecha 
              ?? Date.new($hasta-fecha)
              !! Date.today;

    $venganzas.mp3-a-ogg if $convertir-a-ogg;
    $venganzas.del-pasado($desde, $hasta) unless $nono;

    $no-filtrar
        ?? $venganzas.del-pasado($desde, $hasta, :sin-filtro)
        !! $venganzas.del-pasado($desde, $hasta);

    if $nono {

        $descarga-directa
            ?? $venganzas.descargar(:simular, :descarga-directa)
            !! $venganzas.descargar(:simular);

    } else {

        $descarga-directa
            ?? $venganzas.descargar(:descarga-directa)
            !! $venganzas.descargar;

    }

}
