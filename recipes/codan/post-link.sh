#!/bin/bash

if [ -d "$PREFIX/lib/perl5/site_perl/5.22.0/Bio/" ]; then
  #conda env config vars set PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0/ -n $(basename $PREFIX)
  echo "Warning: notice that conda installed Perl 5.26 but all libraries are installed in Perl 5.22 path." >> $PREFIX/.messages.txt
  echo "Please, use the command below to ensure all libraries will properly work:" >> $PREFIX/.messages.txt
  echo "conda env config vars set PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0/ -n ENV_NAME" >> $PREFIX/.messages.txt
  echo "    whereas ENV_NAME should be the name indicated in the -n option" >> $PREFIX/.messages.txt
fi
