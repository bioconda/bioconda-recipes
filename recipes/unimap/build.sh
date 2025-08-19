#! /bin/sh

git clone https://github.com/DLTcollab/sse2neon.git
cp sse2neon/sse2neon.h .
sed -i '9c #include "sse2neon.h"'  ksw2_ll_sse.c
sed -i '9c #include "sse2neon.h"'  ksw2_extz2_sse.c
sed -i '10c #include "sse2neon.h"' ksw2_extd2_sse.c
sed -i '10c #include "sse2neon.h"' ksw2_exts2_sse.c

make arm_neon=1 aarch64=1\
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS} -DHAVE_KALLOC"

install -d "${PREFIX}/bin"
install unimap "${PREFIX}/bin/"
