#!/bin/bash

if [ -d "$PREFIX/lib/perl5/site_perl/5.22.0/Bio/" ]; then
  conda env config vars set PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0/ -n $(basename $PREFIX)
fi
