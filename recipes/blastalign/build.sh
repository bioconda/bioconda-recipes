#!/bin/bash

mkdir -p $PREFIX/bin
cp BlastAlign* $PREFIX/bin

<<<<<<< HEAD
#sed -i "s/perl/env perl/" $PREFIX/bin
=======
sed -i "s/perl/env perl/" $PREFIX/bin
>>>>>>> 2dd04dd6bcd3a0c74b17d6b6489998b1d53c8a76
