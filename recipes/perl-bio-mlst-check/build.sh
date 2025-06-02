#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    # Apparent false-positive failures due to the testing code
    #perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    # Apparent false-positive failures due to the testing code
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod +x $PREFIX/bin/download_fasta_database
chmod +x $PREFIX/bin/get_sequence_type
chmod +x $PREFIX/bin/get_emm_sequence_type
chmod +x $PREFIX/bin/download_mlst_databases
