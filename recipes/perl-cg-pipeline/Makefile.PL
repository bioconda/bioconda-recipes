use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'CG-Pipeline',
    AUTHOR           => q{Lee Katz <lkatz@cdc.gov>},
    VERSION          => '0.5',
    ABSTRACT         => 'Perl libraries required for CG-Pipeline.',
    LICENSE          => 'gpl',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    PREREQ_PM => {
        'Data::Dumper'       => 0,
        'File::Basename'     => 0,
        'File::Spec'         => 0,
        'File::Temp'         => 0,
        'List::Util'         => 0,
    },
);
