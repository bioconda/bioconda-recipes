#!/bin/bash


# Create a binary directory in conda environment 

mkdir -p $PREFIX/bin


# Insert the perl shebang into the final destination file 

echo '#!/usr/bin/env perl' > $PREFIX/bin/CIRI2.pl

# Append the contents of unzipped script to it

cat CIRI_v*/CIRI*.pl >> $PREFIX/bin/CIRI2.pl

# Make it executable 

chmod +x $PREFIX/bin/CIRI2.pl