# For inspiration, see also Debian's ncbi-vdb package:
# https://salsa.debian.org/med-team/ncbi-vdb

# This is a non-autotools configuration system. The usual ./configure options
# don’t work. Paths to toolchain binaries (gcc, g++, ar) are in part hard-coded
# and need to be patched.

sed -i.backup \
    -e "s|gcc|$CC|g" \
    -e "s|g++|$CXX|g" \
    build/Makefile.gcc

# * --debug lets the configure script print extra info
# * Only LDFLAGS and CXX can be customized at configure time.
./configure \
    --debug \
    --prefix=$PREFIX \
    --build-prefix=ncbi-outdir \
    --with-ngs-sdk-prefix=$PREFIX \
    CXX=$CXX

# Edit the generated build configuration to use the proper tools
# sed -i.backup \
#     -e "s|= gcc|= $CC|" \
#     -e "s|= g++|= $CXX|" \
#     -e "s|= ar rc|= ar|" \
#     -e "s|= ar|= $AR|" \
#     build/Makefile.config.linux.x86_64

make

# This does not install the header files
make install

# These tests fail sometimes because they try to access online resources
make -C test/vdb

# Copy headers manually. As done by Debian, install them into a common subdirectory
mv interfaces/* $PREFIX/include/ncbi-vdb


# To Do

# Some of the internal libraries are not built. These messages are printed during the build:

# NOTE - internal library libkff cannot be built: It requires 'libmagic' and its development headers.
# NOTE - internal library libkxml cannot be built: It requires 'libxml2' and its development headers.
# NOTE - internal library libkxfs cannot be built: It requires 'libxml2' and its development headers.
# NOTE - library libkdf5 cannot be built: It requires 'libhdf5' and its development headers.
# NOTE - library libvdb-sqlite cannot be built: It requires 'libxml2'.

# These other notes are written at configure time:

# bison: command not found
# bc: command not found
