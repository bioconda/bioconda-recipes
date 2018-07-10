#!/bin/bash

mkdir -p ${PREFIX}/bin

sed -i.bak "s:/usr/bin/perl:/usr/bin/env perl:" ssake/SSAKE
sed -i.bak "s:/usr/bin/perl:/usr/bin/env perl:" ssake/tools/*.pl
sed -i.bak "s:/home/martink/bin/perl:/usr/bin/env perl:" ssake/tools/getStats.pl
sed -i.bak "s:/usr/bin/python:/usr/bin/env python:" ssake/tools/*.py

cp ssake/SSAKE ${PREFIX}/bin
cp ssake/tools/*.pl ${PREFIX}/bin
cp ssake/tools/*.py ${PREFIX}/bin

chmod +x ${PREFIX}/bin/*.py
chmod +x ${PREFIX}/bin/*.pl
chmod +x ${PREFIX}/bin/SSAKE
