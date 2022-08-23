#!/bin/bash
rm t/Bio/Roary/CommandLine/Roary.t
rm t/Bio/Roary/External/CheckTools.t

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    ##perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    ##make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

wget https://raw.githubusercontent.com/sanger-pathogens/Roary/master/bin/create_pan_genome_plots.R -P $PREFIX/bin/

chmod u+rwx $PREFIX/bin/create_pan_genome_plots.R
chmod u+rwx $PREFIX/bin/roar*
chmod u+rwx $PREFIX/bin/pan_*
chmod u+rwx $PREFIX/bin/create_*
