#!/bin/bash
mkdir -p $PREFIX/bin
chmod +x *pl
sed -i -e 's/\r/\n/g' proTRAC_2.1.pl
sed -i -e 's/\/perl/\/env perl/' proTRAC_2.1.pl
cp proTRAC_2.1.pl $PREFIX/bin
