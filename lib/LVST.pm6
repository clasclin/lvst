unit module LVST;

use LVST::Config;

Config.new;


class LVST::Audio {
    has $.nombre;
    has $.ubicación;
    has $.extensión;
    has Date $.fecha;
    has $.año;
    has $.mes;
    has $.día;
    has $.tamaño;
}


class LVST::Venganzas {

   has LVST::Audio @.programas-ogg;
   has LVST::Audio @.programas-mp3;
   has @.pendientes;

   method !buscar-audios($path, $save-in) {
       my @stack = $path.IO;

       my $audio-files = gather while @stack {
           with @stack.pop {
                when :d { @stack.append: .dir }
                when .extension eq 'ogg' or .extension eq 'mp3' {
                    .take;
                }
           }
       }

       $audio-files.map(&create-audio);

       sub create-audio($audio) {
           my $name = $audio.basename;
           my $ext  = $audio.extension;
           my $path = $audio.dirname;
           my $date = ~$0 
               if $name ~~ /
                   [ 'dolina_' \d**4 '_'  ||  'lavenganza_' ]
                   (       \d**4 '-' \d**2 '-' \d**2        )
                   [ '_' \d+ ]?          [ '.ogg' || '.mp3' ] $/;

           my ($year, $month, $day) = ~$0, ~$1, ~$2
               if $date ~~ /
                   ( \d**4 ) '-' ( \d**2 ) '-' ( \d**2 ) /;

           my $size = $audio.IO.s; 

           $save-in.push: LVST::Audio.new(
               nombre    => $name,
               ubicación => $path,
               extensión => $ext,
               fecha     => Date.new($date),
               año       => $year,
               mes       => $month,
               día       => $day,
               tamaño    => $size,
           );
       } 
   }

   method último-programa() {
       return @!programas-ogg>>.fecha.sort.tail;
   }

   method del-pasado(Date $desde! is copy, Date $hasta! is copy, Bool :$sin-filtro) {
       if $desde lt $hasta {
           my @fechas = lazy gather {
               until $desde eq $hasta {
                   unless $desde.day-of-week == 6|7 { # sábado y domingo no hay programa
                       take $desde;
                   }
                   $desde .= later(:1day);
               }
           }
           @!pendientes := @fechas;
       } else {
           note "'$desde' tiene que ser menor que '$hasta'";
       }
   }

   method descargar(Bool :$descarga-directa, Bool :$simular) {
       chdir "$Config::mp3" or die "$!";

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
                   once { say "Descargando..." }
                   shell "wget $url-completa";
                   sleep 3;
               }
           }
       }
   }

   method mp3-a-ogg () {
       say "Convirtiendo a ogg...";

       my %p-mp3 = map { .fecha => $_ }, @!programas-mp3;
       my %p-ogg = map { .fecha => $_ }, @!programas-ogg;

       for %p-mp3.keys.sort {
           %p-mp3{$_}:delete if %p-ogg{$_}:exists;
       }

       for %p-mp3.values -> $audio {
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
       self!buscar-audios($Config::ogg, @!programas-ogg);
       self!buscar-audios($Config::mp3, @!programas-mp3);
   }
}
