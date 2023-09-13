#!/bin/bash
mkdir -p ${PREFIX}/bin
cp translatorx_vLocal.pl $PREFIX/bin

chmod +x $PREFIX/bin/translatorx_vLocal.pl
ln $PREFIX/bin/translatorx_vLocal.pl $PREFIX/bin/translatorx
