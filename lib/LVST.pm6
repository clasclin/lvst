unit module LVST;

use LVST::Config;

Config.new;


class LVST::Audio {

    has $.name;
    has $.path;
    has $.year;
    has $.month;
    has $.day;
    has $.size;

    method change-ext () {
        $!name .= subst('dolina_' ~ $!year ~ '_', '');
        $!name .= subst('mp3', 'ogg');
    }
}


class LVST::Venganzas {

   has %!audios-ogg;
   has %!audios-mp3;
   has @!missing;

   method !buscar-audios ($path, $save-in) {
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

       sub create-audio ($audio) {
           my $name = $audio.basename;
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

           $save-in.push: $date => LVST::Audio.new(
               name  => $name,
               path  => $path,
               year  => $year,
               month => $month,
               day   => $day,
               size  => $size,
           );
       } 
   }

   method último-programa () {
       Date.new(%!audios-ogg.keys.sort.tail);
   }

   method del-pasado (Date $desde! is copy, Date $hasta! is copy, Bool :$sin-filtro) {
       if $desde lt $hasta {
           my @fechas = lazy gather {
               until $desde eq $hasta {
                   # sábado y domingo no hay programa
                   unless $desde.day-of-week == 6|7 { 
                       take $desde;
                   }
                   $desde .= later(:1day);
               }
           }
           @!missing := @fechas;
       } else {
           note "'$desde' tiene que ser menor que '$hasta'";
       }
   }

   method descargar (Bool :$descarga-directa, Bool :$simular) {
       chdir "$Config::mp3" or die "$!";

       for @!missing -> Date $date {
           my Str $base-url  = 'http://s3.schwindt.org/dolina/';
           my Str $file-name = 'lavenganza_' ~ $date ~ '.mp3?torrent';

           if $descarga-directa {
               $base-url     = 'https://venganzasdelpasado.com.ar/';
               $file-name    = 'lavenganza_' ~ $date ~ '.mp3';
           }

           my $url = $base-url ~ $date.year ~ '/' ~ $file-name;
           say "simulando: wget $url" if $simular;

           unless $file-name.IO.f {
               unless $simular {
                   once { say "Descargando..." }
                   shell "wget $url";
                   sleep 3;
               }
           }
       }
   }

   method mp3-a-ogg () {

       for %!audios-mp3.keys -> $date {
           if %!audios-ogg{$date}:exists {
               %!audios-mp3{$date}:delete;
           }
       }

       for %!audios-mp3.values -> $audio {
           my $src  = IO::Spec::Unix.join($, $audio.path, $audio.name);
           my $dir  = IO::Spec::Unix.join($, $Config::ogg, $audio.year);

           $audio.change-ext;
           my $dst  = IO::Spec::Unix.join($, $dir, $audio.name);

           mkdir $dir unless $dir.IO.d;
           my $total-size = 0;

           my @jobs;
           unless $dst.IO.f {
               $total-size += $audio.size;

               my $proc = Proc::Async.new('mp3-a-ogg.sh', $src, $dst);
               push @jobs, $proc.start;

               if @jobs == 3 {
                   await Promise.anyof(@jobs);
                   @jobs .= grep({ !$_ });
               }
           }
           say "Convirtiendo a ogg";
           say "Espacio requerido: { floor($total-size * 1e-6) } MB";
           await @jobs;
       }
   }

   submethod BUILD () {
       self!buscar-audios($Config::ogg, %!audios-ogg);
       self!buscar-audios($Config::mp3, %!audios-mp3);
   }
}
