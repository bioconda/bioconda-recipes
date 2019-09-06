#!/bin/bash

PKG_VERSION=0.24.0
SVA_HOME=$PREFIX/opt/svanalyzer-$PKG_VERSION

# cd to location of Build file and build:

cd $SVA_HOME

perl Build.PL
perl ./Build
perl ./Build test
perl ./Build install --installdirs site

