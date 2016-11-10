unit module Fechas;

my $aaaa-mm-dd-regex = /:r ^  \d**4  '-'  \d**2  '-'  \d**2  $ /;    # AÑO-MES-DÍA 
my $dd-mm-aaaa-regex = /:r ^ (\d**2) '-' (\d**2) '-' (\d**4) $ /;    # DÍA-MES-AÑO 
my $fecha-regex      = /:r $aaaa-mm-dd-regex || $dd-mm-aaaa-regex /; # AÑO-MES-DÍA o DÍA-MES-AÑO 

subset FechaVálida is export of Str where $fecha-regex; 

sub convertir-fecha($día-mes-año) is export {
    if $día-mes-año.match($dd-mm-aaaa-regex) { return "$2-$1-$0" }
    elsif $día-mes-año.match($aaaa-mm-dd-regex) { return $día-mes-año }
}
