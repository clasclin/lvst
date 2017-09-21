#!/usr/bin/env perl6
#
# mp3-a-ogg - convert mp3 files to ogg
#

use v6;


sub MAIN ($input-file, $output-file) {
    my $mp3 = run 'mpg123', '--quiet', '--wav', '-', $input-file, :out;
    my $ogg = run 'oggenc', '--quiet', '--quality', '-1', '-o', $output-file, '-',
              :in($mp3.out);
}

