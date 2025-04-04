#!/bin/bash
mkdir -p ${PREFIX}/bin
cp CopraRNA2.pl  ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/CopraRNA2.pl
cp -r coprarna_aux ${PREFIX}/bin/
chmod 755 ${PREFIX}/bin/coprarna_aux/*.pl
chmod 755 ${PREFIX}/bin/coprarna_aux/*.R
chmod 755 ${PREFIX}/bin/coprarna_aux/*.pl

