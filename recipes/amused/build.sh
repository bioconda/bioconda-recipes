#!/bin/bash
libloc="$PREFIX/lib/ruby/site_ruby"
mkdir -p $libloc
mkdir -p $PREFIX/bin
cp ./NMERTREE.rb $libloc/. 
cp ./AMUSED $PREFIX/bin/. 
cp ./AMUSED-KS $PREFIX/bin/. 
cp ./alignKMers $PREFIX/bin/. 
cp ./shuffleCodons.rb $PREFIX/bin/. 
cp ./shuffleCodonsAddMotifs.rb $PREFIX/bin/. 
