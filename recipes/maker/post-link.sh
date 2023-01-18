#!/usr/bin/env bash

cat >> "${PREFIX}"/.messages.txt <<- EOF

##########################################################################################

  !!! MAKER: RESTRICTION FOR COMMERCIAL USAGE !!!

  The MAKER authors specifically allowed to make it available in Bioconda, under GPL3
  license. But be aware that MAKER2/3 is free for academic use, but commercial Bioconda
  and Galaxy users of MAKER2/3 still need a license, which can be obtained here:

    http://weatherby.genetics.utah.edu/cgi-bin/registration/maker_license.cgi

  An official statement of the authors on this subject can be consulted on this page:

    https://github.com/galaxyproject/iwc/pull/47#issuecomment-962260646

##########################################################################################
EOF
