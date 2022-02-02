#!/bin/sh
TARGET=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

cd "$TARGET/"
perl autoInstall.pl -condaDBinstall

cat >> "$PREFIX/.messages.txt" <<EOF
Due to licence restrictions, if you would like to use usearch for OTU clustering
(uparse, unoise) and mapping, you need to download and install it from

http://www.drive5.com/usearch/download.html

and then execute:

lotus2 -link_usearch <path to usearch>

from within your lotus2 conda environment.
EOF
