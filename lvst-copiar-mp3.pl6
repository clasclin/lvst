#!/usr/bin/env perl6
#
# lvst-copiar-mp3.pl6 - está pensado para ejecutarse post descarga por el
# cliente bittorrent
#

use v6;


my Str $año   = Date.today.year.Str;
my Str $org   = "$*HOME/Descargas/torrents";
my Str $dst   = "$*HOME/Música/lvst/$año";
my Regex $pre = /:r 'dolina_' \d**4 '_' /;


multi MAIN (Str $archivo!, :$quitar = $pre) {
    # subrutina creada para cliente bittorrent
    if $archivo.IO.basename ~~ /^ 'dolina_' $año .+ mp3 $/ {
        my Str $viejo-nombre = $archivo.IO.basename;
        my Str $nuevo-nombre = $archivo.IO.basename.subst($quitar, '');
        copy("$org/$viejo-nombre", "$dst/$nuevo-nombre", :createonly);
    }
}


multi MAIN (:$quitar = $pre, Bool :$nono) {
    # subrutina creada para ser usada por lvst.pl6
    if $dst.IO.d {
        for dir($org, test => /:i $año .+ mp3 $/) -> $audio {
            my Str $nuevo-nombre = $audio.basename.subst($quitar, '');
            with    $nono { say "$audio -> $dst/$nuevo-nombre" }
            without $nono {
	        copy("$audio", "$dst/$nuevo-nombre", :createonly)
	            unless "$dst/$nuevo-nombre".IO.e
            }
        }
    } 
}
