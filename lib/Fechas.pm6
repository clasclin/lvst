unit module Fechas;

my token año-mes-día { ^  \d**4  '-'  \d**2  '-'  \d**2  $ }; # AÑO-MES-DÍA
my token día-mes-año { ^ (\d**2) '-' (\d**2) '-' (\d**4) $ }; # DÍA-MES-AÑO
my token fecha       { <día-mes-año> || <año-mes-día> };      # AÑO-MES-DÍA o DÍA-MES-AÑO

subset FechaVálida is export of Str where &fecha;


sub convertir-fecha (Str $fecha) is export {
    # convierte el formato de la fecha a año-mes-día de ser necesario
    $fecha.match(&día-mes-año) ?? return "$/[2]-$/[1]-$/[0]" !! return $fecha;
}
