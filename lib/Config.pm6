use v6;

unit module Config;


#| clase que ayuda con los datos de configuración
class LVST::Configuración {

    has %.variables;

    sub leer-configuración ($archivo) {

        my %config;
        for $archivo.IO.lines -> $línea {

            # ignorar comentarios
            next if $línea.starts-with('#');

            next unless $línea ~~ /^ (.*?) '=' (.*?) $/;

            %config{~$0.trim} = ~$1.subst('~', %*ENV{'HOME'}).trim;

        }

        return %config;
    }

    sub configuración-por-defecto ($archivo) {

        $archivo.IO.spurt(q:to"FIN");

        # archivo de configuración de lvst
        # los directorios pueden ser absolutos o relativos a home

        # directorio donde se van a guardar los torrents
        archivos.descargados = ~/Descargas/torrents/venganzas-del-pasado

        # directorio donde se van a guardar los ogg
        archivos.locales     = ~/Música/lvst

        FIN

    }

    submethod BUILD () {

        my $config   = %*ENV{'HOME'} ~ '/.lvst';

        configuración-por-defecto($config)
            unless $config.IO.e;

        %!variables := leer-configuración($config);

    }
} 
