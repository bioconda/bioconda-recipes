#!/bin/bash

sed -i.bak 's|/usr/bin/perl -w|/usr/bin/env perl|' setup-deps.pl
sed -i.bak 's|/usr/bin/perl -w|/usr/bin/env perl|' asp-ls
sed -i.bak 's|/usr/bin/perl -w|/usr/bin/env perl|' run-ncbi-converter
sed -i.bak 's|/usr/bin/perl -w|/usr/bin/env perl|' ftp-cp
sed -i.bak 's|/usr/bin/perl -w|/usr/bin/env perl|' ftp-ls

sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' gbf2xml
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' nquire
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' edirect.pl
sed -i.bak 's|/usr/bin/perl|/usr/bin/env perl|' edirutil

mv * "$PREFIX/bin/"
mkdir -p "$PREFIX/home"
export HOME="$PREFIX/home"
sh ${PREFIX}/bin/setup.sh

