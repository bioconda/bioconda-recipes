use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'LyveSET',
    AUTHOR           => q{Lee Katz <lkatz@cdc.gov>},
    VERSION          => '2.0.1',
    ABSTRACT         => 'Perl libraries required for Lyve-SET.',
    LICENSE          => 'mit',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    PREREQ_PM => {
        'Data::Dumper'       => 0,
        'File::Basename'     => 0,
        'File::Spec'         => 0,
        'File::Slurp'        => 0,
        'File::Temp'         => 0,
        'String::Escape'     => 0,
    },
);
