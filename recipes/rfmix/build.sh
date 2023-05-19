# following full suggested build path of rfmix
aclocal                      # creates aclocal.m4
autoheader                   # creates config.h.in
autoconf                     # creates configure
automake --add-missing       # creates Makefile.in
./configure                  # generates the Makefile
make

# Install
mkdir -p $PREFIX/bin
cp {rfmix,simulate} $PREFIX/bin/