#!/usr/bin/env perl6
#
# lvst.pl6 - script principal que se encarga de descargar los torrents del
# programa 'La Venganza Será Terrible' con la ayuda de otros scripts los cuales
# también se puede usar de forma independiente. Para ejemplos véase README.md
#

use v6;


my Str $descargas  = "$*HOME/Descargas/torrents";
my Str $año        = Date.today.year.Str;
my Str $dir-audios = "$*HOME/Música/lvst/$año";


sub MAIN (Str $guardar-en = $descargas, Str $buscar-en = $dir-audios, Bool :$nono) {

    chdir $guardar-en or die "$!";

    shell 'lvst-copiar-mp3.pl6' unless $nono;

    my $desde-fecha = qqx{lvst-consultar-programa.pl6 $buscar-en};
    my $fechas      = qqx{venganzas-del-pasado.pl6 --torrents $desde-fecha} if $desde-fecha;
    my @venganzas   = $fechas.split("\n", :skip-empty) if $fechas;

    if @venganzas {
        for @venganzas -> Str $url {
            with    $nono { say   "wget $url" }
            without $nono { shell "wget $url" }
        }
    }
    else {
        say "Nada que descargar";
    }
}
