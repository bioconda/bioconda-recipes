use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Bio::Pfam',
    AUTHOR           => q{Pierre-Alain Chaumeil and Donovan Parks <p.chaumeil@uq.edu.au>},
    VERSION          => '0.1.3',
    ABSTRACT         => 'Perl script and dependent library files required for GTDB-Tk',
    LICENSE          => 'gpl_3',
    PL_FILES         => {},
    EXE_FILES        => [ qw(pfam_search.pl) ],
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    PREREQ_PM => {
        'Moose'          => 0,
        'IPC::Run'       => 0,
        'File::Basename' => 0,
        'Getopt::Long'   => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Bio-Pfam-*' },
);
