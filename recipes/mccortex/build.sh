#!/usr/bin/env bash
set -x

export CFLAGS="-I$PREFIX/include -fcommon"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=$PREFIX/include
export CC="${CC} -fcommon"
export CXX="${CXX} -fcommon"

for make_file in libs/string_buffer/Makefile $(find libs/seq_file -name Makefile) $(find libs/seq-align -name Makefile) Makefile; do
    sed -i.bak 's/-lz/-lz $(LDFLAGS)/' $make_file
    if [[ ${target_platform} =~ linux.* ]] ; then
      sed -i.bak 's/-m64//' $make_file
    fi
done

if [[ ${target_platform} =~ linux.* ]] ; then
    sed -i "28c\\\tcd htslib && autoreconf --install && ./configure --disable-lzma --disable-bz2 --disable-libcurl && \$(MAKE) " libs/Makefile
fi

make MAXK=31
make MAXK=63
make MAXK=95
make MAXK=127

sed -i.bak '1 s|^.*$|#!/usr/bin/env bash|g' bin/mccortex && rm bin/mccortex.bak

mkdir -p $PREFIX/bin
install -p bin/* $PREFIX/bin

