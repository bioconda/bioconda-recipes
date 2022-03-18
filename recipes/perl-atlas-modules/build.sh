#!/bin/bash

## Hack to get around hardcoded paths in perl modules and config requirements
atlasprodDir=${PREFIX}/atlasprod
mkdir -p $atlasprodDir
cp -r $SRC_DIR/perl_modules $atlasprodDir
cp -r $SRC_DIR/supporting_files $atlasprodDir

# Path to installed perl libs from CPAN

## perl version
perl_version=$(perl -e 'print $^V');
perl_version=${perl_version:1}

PERLLIB="${PREFIX}/lib/perl5/${perl_version}/perl_lib"
mkdir -p $PERLLIB

## install modules from CPAN directly as they are no conda packages for these modules

# A little hack to try to nudge Bioconda MacOS CI- which seems to have HOME set
# to 'UNKNOWN' which disrupts cpanm

if [[ ${HOST} =~ .*darwin.* && ("$HOME" == 'UNKNOWN' || -z "$HOME") ]]; then
    export HOME=/Users/distiller
fi

cpanm -l $PERLLIB MooseX::FollowPBP \
                    URI::Escape \
                    Config::YAML \
                    File::Basename \
                    Bio::MAGETAB \
                    Date::Parse \
                    Test::MockObject \
                    Text::TabularDisplay \
                    Log::Dispatch::File \
                    TIMB/DBI-1.636.tar.gz \
                    MIYAGAWA/Class-Trigger-0.15.tar.gz \
                    TMTM/Class-DBI-v3.0.17.tar.gz \
                    DETI/Proc/Proc-Daemon-0.14.tar.gz \
                    Proc::ProcessTable


cpanm -l $PERLLIB --force Mail::Sendmail \
                          Log::Dispatch::File 

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PERL5LIB=$PERL5LIB:$atlasprodDir/perl_modules:$PERLLIB/lib/perl5" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

patch ${PREFIX}/lib/perl5/5.26.2/perl_lib/lib/perl5/Class/DBI.pm ${RECIPE_DIR}/Class-DBI_last_insert.patch
