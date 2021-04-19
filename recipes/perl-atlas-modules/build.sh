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

if [[ ${HOST} =~ .*darwin.* ]]; then
    export HOME=/Users/distiller
fi

cpanm -l $PERLLIB MooseX::FollowPBP \
                    URI::Escape \
                    URL::Encode \
                    Config::YAML \
                    File::Basename \
                    Bio::MAGETAB \
                    Date::Parse \
                    Test::MockObject \
                    Text::TabularDisplay \
                    Log::Dispatch::File \
                    IO::CaptureOutput \
                    Class::DBI

mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export PERL5LIB=$PERL5LIB:$atlasprodDir/perl_modules:$PERLLIB/lib/perl5" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh
