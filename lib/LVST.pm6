unit module LVST;

use LVST::Config;

Config.new;


class LVST::Audio {
    has $.name;
    has $.src;
    has $.dst;
    has $.date;
    has $.size;
    has $.ext;

    method download (Bool $simular?) {
        my $base-url = 'http://s3.schwindt.org/dolina/';
        my $url = $base-url ~ $!date.year ~ '/' ~ $!name ~ '?torrent';
        say "--> $url" if $simular;
        unless $simular { 
            run 'wget', $url;
        }
    }

    method rename-file {
        $!name.subst($!name, "lavenganza_$!date.ogg");
    }
}


class LVST::Venganzas {
    has %.audios;
    has @.to-download;
    has @.to-ogg;

    method buscar-audios ($path) {
        my @stack = $path.IO;
        my @audio-files = lazy gather while @stack {
            with @stack.pop {
                 when :d { @stack.append: .dir }
                 when .extension eq 'ogg'|'mp3' {
                     .take;
                 }
            }
        }
        for @audio-files -> $audio {
            my $name = $audio.basename;
            my $src  = $audio.dirname;
            my $date = Date.new(~$0) 
                if $name ~~ / .+? ( \d**4 '-' \d**2 '-' \d**2 ) .+? /;
            my $dst  = "$Config::ogg/{$date.year}";
            my $size = $audio.IO.s; 
            my $ext  = $audio.extension;

            %!audios.push: 
                $ext => LVST::Audio.new(:$name, :$src, :$dst, :$date, :$size, :$ext);
        } 
    }

    method último-programa ($ext = 'ogg') {
        %!audios{$ext}>>.date.sort.tail;
    }

    method del-pasado (Date $desde! is copy, Date $hasta! is copy) {
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
            for @fechas -> $date {
                if any(%!audios{'ogg'}>>.date) {
                    @!to-download.push: LVST::Audio.new(
                        name => "lavenganza_$date.mp3",
                        src  => $Config::mp3,
                        dst  => "$Config::ogg/{$date.year}",
                        :$date,
                    );
                }
            }
        } else {
            note "'$desde' tiene que ser menor que '$hasta'";
        }
    }

    method descargar (Bool :$simular) {
        say "simulando descargas" if $simular;
        for @!to-download -> $audio {
            if $simular {
                $audio.download($simular);
            }
            else {
                indir $Config::mp3, {
                    unless "{$audio.src}/{$audio.name}?torrent".IO.e {
                        my $wget = $audio.download;
                        sleep 2;
                        next if $wget.exitcode != 0; 
                    }
                }
            }
        }
    }

    method mp3-a-ogg {
        my %mp3 = map { .date => $_ }, %!audios{'mp3'}.flat;
        my %ogg = map { .date => $_ }, %!audios{'ogg'}.flat;

        for %mp3.kv -> $date, $audio {
            unless %ogg{$date}:exists {
                push @!to-ogg, $audio;
            }
        }

        my @works;
        for @!to-ogg -> $audio {
            mkdir $audio.dst unless $audio.dst.IO.d;
            my $src  = "{$audio.src}/{$audio.name}";
            my $dst  = "{$audio.dst}/{$audio.rename-file}";

            my $proc = Proc::Async.new('mp3-a-ogg.pl6', $src, $dst);
            push @works, $proc.start;

            if @works == 2 {
                await Promise.anyof(@works);
                @works .= grep({ !$_ });
            }
        }
        await @works;
    }

    submethod BUILD {
        self.buscar-audios($Config::mp3);
        self.buscar-audios($Config::ogg);
    }
}

