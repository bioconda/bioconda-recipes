#!/bin/bash

cat <<EOF >> ${PREFIX}/.messages.txt
To use this package you will need to use the included training sets.
These can be found at $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

Example for human samples:  genesplicer <fasta-file> $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/human

For more information, see https://ccb.jhu.edu/software/genesplicer/