#!/bin/bash
cp CopraRNA2.pl  ${PREFIX}/bin
chmod 755 ${PREFIX}/bin/CopraRNA2.pl
cp -r coprarna_aux ${PREFIX}/
chmod 755 ${PREFIX}/bin/*.pl
chmod 755 ${PREFIX}/bin/*.R
chmod 755 ${PREFIX}/bin/*.pl
chmod 755 ${PREFIX}/bin/phantomjs

