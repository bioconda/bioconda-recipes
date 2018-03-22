#!/bin/bash
libloc="$PREFIX/lib/ruby/site_ruby"
mkdir -p $libloc
mkdir -p $PREFIX/bin
cp Ruby-DNA-Tools/*.rb $libloc/. 
cp AMUSED/NMERTREE.rb $libloc/. 
cp AMUSED/AMUSED $PREFIX/bin/. 
cp AMUSED/AMUSED-KS $PREFIX/bin/. 
cp AMUSED/alignKMers $PREFIX/bin/. 
cp AMUSED/shuffleCodons.rb $PREFIX/bin/. 
cp AMUSED/shuffleCodonsAddMotifs.rb $PREFIX/bin/. 
