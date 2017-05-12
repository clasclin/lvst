unit module LVST;

use LVST::Config;

Config.new;


#| clase que sirve de plantilla para cada programa de radio
class LVST::Audio {

    has Str $.nombre;
    has IO::Path $.ubicación;
    has Str $.extensión;
    has Date $.fecha;
    has Str $.año;
    has Str $.mes;
    has Str $.día;
    has Int $.tamaño;

}


#| clase que gestiona los programas de radio
class LVST::Venganzas {

   has LVST::Audio @.programas;
   has Date @.pendientes;

   # usado en BUILD 
   method !buscar-audios ($buscar-en) {

       my @directorios = $buscar-en.IO;

       while @directorios {

           for @directorios.pop.dir -> $audio {

               if $audio.f {

                   if $audio.ends-with('.ogg') or $audio.ends-with('.mp3') {

                       my Str $nombre          = $audio.basename;
                       my Str $extensión       = $audio.extension;
                       my IO::Path $directorio = $audio.dirname.IO;
                       my Str $fecha           = ~$0 if $nombre ~~ /
                           [ 'dolina_' \d**4 '_'  ||  'lavenganza_' ]
                           (       \d**4 '-' \d**2 '-' \d**2        )
                           [ '_' \d+ ]?          [ '.ogg' || '.mp3' ]
                           $/;

                       my (Str $año, Str $mes, Str $día) = ~$0, ~$1, ~$2
                           if $fecha ~~ /
                           ( \d**4 ) '-' ( \d**2 ) '-' ( \d**2 ) /;

                       my Int $tamaño = $audio.IO.s;

                       @!programas.push: LVST::Audio.new(
                           :nombre($nombre),
                           :ubicación($directorio),
                           :extensión($extensión),
                           :fecha(Date.new($fecha)),
                           :año($año),
                           :mes($mes),
                           :día($día),
                           :tamaño($tamaño),
                       );

                   }

               }

               @directorios.push: $audio if $audio.d;
           }
       }
   }

   method último-programa () {

       my LVST::Audio @oggs = grep { .extensión eq 'ogg' }, @!programas;
       return @oggs>>.fecha.sort.tail;

   }

   method del-pasado (Date $desde! is copy, Date $hasta! is copy, Bool :$sin-filtro) {

       my Date %rango;

       if $desde lt $hasta {

           until $desde eq $hasta {

               unless $desde.day-of-week == 6|7 { # sábado y domingo no hay programa

                   %rango.push: $desde => $desde;

               }

               $desde .= later(:1day);
           }
       }

       map { %rango{$_}:delete }, @!programas>>.fecha unless $sin-filtro;
       @!pendientes.append: %rango.values.sort;

   }

   method descargar (Bool :$descarga-directa, Bool :$simular) {

       chdir "$Config::mp3" or die "$!";

       say "Descargando...";

       for @!pendientes -> Date $fecha {

           my Str $url     = 'http://s3.schwindt.org/dolina/';
           my Str $archivo = 'lavenganza_' ~ $fecha ~ '.mp3?torrent';

           if $descarga-directa {

               $url = 'https://venganzasdelpasado.com.ar/';
               $archivo = 'lavenganza_' ~ $fecha ~ '.mp3';

           }

           my $url-completa = $url ~ $fecha.year ~ '/' ~ $archivo;

           say "simulando: wget $url-completa" if $simular;

           unless $archivo.IO.f {

               unless $simular {
                   shell "wget $url-completa";
                   sleep 3;
               }

           }
       }
   }

   method mp3-a-ogg () {

       say "Convirtiendo a ogg...";

       my LVST::Audio @mp3 = grep { .extensión eq 'mp3' }, @!programas;
       my LVST::Audio @ogg = grep { .extensión eq 'ogg' }, @!programas;

       my LVST::Audio %mp3 = map { .fecha => $_ }, @mp3;
       my Int   %ogg = map { .fecha => 1  }, @ogg;

       map { %mp3{$_}:delete if %ogg{$_}:exists }, %mp3.keys.sort;

       for %mp3.values -> $audio {

           my $origen  = $audio.ubicación ~ '/' ~ $audio.nombre;
           my $nombre  = $audio.nombre.subst('dolina_' ~ $audio.año ~ '_', '')\
                         .subst($audio.extensión, 'ogg');
           my $destino = $Config::ogg ~ '/' ~  $audio.año;

           mkdir $destino unless $destino.IO.d;
           $destino ~= '/' ~ $nombre;

           my @trabajos;

           unless $destino.IO.f {

               my $proc = Proc::Async.new('mp3-a-ogg.sh', $origen, $destino);
               push @trabajos, $proc.start;

               if @trabajos == 3 {

                   await Promise.anyof(@trabajos);
                   @trabajos .= grep({ !$_ });

               }
           }

           await @trabajos;
       }
   }

   submethod BUILD () {

       self!buscar-audios($Config::ogg);
       self!buscar-audios($Config::mp3);

   }

}
