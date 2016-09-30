use 5.022000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'VelvetOpt',
    VERSION           => '2.2.5', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT          => 'The VelvetOptimiser is designed to run as a wrapper script for the Velvet assembler (Daniel Zerbino, EBI UK) and to assist with optimising the assembly.', # retrieve abstract from module
    AUTHOR            => 'Simon Gladman & Torsten Seemann',
    LICENSE           => 'gpl',
    #Value must be from legacy list of licenses here
    #http://search.cpan.org/perldoc?Module%3A%3ABuild%3A%3AAPI
);
