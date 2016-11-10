#!/usr/bin/env perl6
#
# lvst-descargar.pl6 - script principal que se encarga de descargar los
# audios con la ayuda de 'lvst-consultar-programa' y 'venganzas-del-pasado'
# por defecto descarga torrents 
#

use v6;

my $descargas = "%*ENV<HOME>/Descargas/torrents";


sub MAIN($ruta = $descargas, Bool :$simular) {
    chdir $ruta or die "No encuentro $ruta";

    my $último-programa = run 'lvst-consultar-programa.pl6', :out;
    my $desde-fecha     = $último-programa.out.words.Str;

    my $enlaces = run 'venganzas-del-pasado.pl6', '--torrents', "$desde-fecha", :out;

    for $enlaces.out.lines -> $enlace { 
        with $simular { run 'echo', 'Simulando descarga', 'wget', "$enlace" }
        without $simular { run 'wget', "$enlace"; sleep 2 }
    }
}
