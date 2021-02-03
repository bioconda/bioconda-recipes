#!/bin/bash

## perl version
perl_version=$(perl -e 'print $^V');
perl_version=${perl_version:1}


## Hack to get around hardcoded paths in perl modules and config requirements
atlasprodDir=${PREFIX}/atlasprod
mkdir -p $atlasprodDir
cp -r $SRC_DIR/perl_modules $atlasprodDir
cp -r $SRC_DIR/supporting_files $atlasprodDir
chmod -R a+x $atlasprodDir

# Path to installed perl libs from CPAN
PERLLIB="${PREFIX}/lib/perl5/${perl_version}/perl_lib"
mkdir -p $PERLLIB && chmod a+x $PERLLIB

## install modules from CPAN directly as they are no conda packages for these modules

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

chmod u+x ${PREFIX}/lib/${perl_version}/*

# See https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.
