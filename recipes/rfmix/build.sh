# following full suggested build path of rfmix

if [[ ${target_platform} == "linux-aarch64" ]]; then
  sed -i 's/\-march=core2/\-march=armv8\-a/g' Makefile.am
fi

aclocal                      # creates aclocal.m4
autoheader                   # creates config.h.in
autoconf                     # creates configure
automake --add-missing       # creates Makefile.in
./configure                  # generates the Makefile
make

# Install
mkdir -p ${PREFIX}/bin
cp {rfmix,simulate} ${PREFIX}/bin/
