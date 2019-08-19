use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;
 
WriteMakefile(
    NAME         => 'Eval',
    AUTHOR       => q{Evan Keibler, <evan@cse.wustl.edu>},
    VERSION_FROM => 'lib/Eval.pm',
    PL_FILES  => {},
    clean => { FILES => 'Eval' },
);
