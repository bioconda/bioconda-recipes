#!/bin/bash

mkdir -p $PREFIX/bin

# To be removed after shebang is fixed is ASCIIGenome repository
sed 's|#!/bin/sh|#!/bin/bash|' ASCIIGenome > $PREFIX/bin/ASCIIGenome
chmod a+x $PREFIX/bin/ASCIIGenome

cp ASCIIGenome.jar $PREFIX/bin/
