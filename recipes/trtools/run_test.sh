#!/usr/bin/env sh

#Note: bioconda's mulled-test part of the build is peculiar in that 
#it runs tests without installing the test.requires to make sure the
#package installation is meaningful with only the things referenced 
#in requirements.run . This means that any tests listed in test.commands
#which rely on test.requires will fail. Instead, put those tests in the 
#run_test.sh file which will be automatically picked up and run during 
#conda-build, but happens not to be run in the mulled build. 
#Source: From the bioconda gitter:
#  @LiterallyUniqueLogin The mulled test ignores the requires: section since 
#  the point of it is to test that only the package and its run time dependencies 
#  are really needed. The normal way we handle this is to put tests with extra 
#  requirements in a run_test.sh file. Since that's not installed with the 
#  package it's then not run in the mulled test (only those tests still in 
#  the meta.yaml are run).

test_trtools.sh
