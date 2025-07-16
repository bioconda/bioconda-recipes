#! /bin/sh

make \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS} -DHAVE_KALLOC"

install -d "${PREFIX}/bin"
install unimap "${PREFIX}/bin/"
