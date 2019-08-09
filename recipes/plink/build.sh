#!/bin/bash

cd 1.9/
mkdir -p ${PREFIX}/bin ${PREFIX}/share/doc

for f in plink_common.h pigz.c dose2plink.c; do
  sed -i.bak -e 's,"\.\./zlib-1.2.11/zlib.h",<zlib.h>,g' "$f"
done

if [[ -z "${OSX_ARCH}" ]]; then
  ## Linux 64 bits only: long int is 64, printf format is ld not lld.
  for f in *.c *.h; do
    sed -i.bak -e 's/define PRId64 "lld"/define PRId64 "ld"/g;s/define PRIu64 "llu"/define PRIu64 "lu"/g' "$f"
  done
fi

ZLIB="-L${PREFIX}/lib -lz"
export LDFLAGS="-L${PREFIX}/lib"

# Build using Makefile.std as recommended in the README
## NO OSX ARCH
if [[ -z "${OSX_ARCH}" ]]; then
  export CFLAGS="-pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fPIC -fexceptions -fstack-protector --param=ssp-buffer-size=4 -std=gnu++11 -Wno-long-long -O3 -I${PREFIX}/include"
  make CFLAGS="${CFLAGS}" BLASFLAGS="${LDFLAGS} -lopenblas" ZLIB="${ZLIB}" -f Makefile.std plink
## OSX ARCH
else
  export CFLAGS="-pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fPIC -fexceptions -fstack-protector --param=ssp-buffer-size=4 -O3 -I${PREFIX}/include"
  make CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" ZLIB="${ZLIB}" -f Makefile.std plink
fi

install -m775 plink ${PREFIX}/bin/
install -m644 ../LICENSE README.md ${PREFIX}/share/doc/
