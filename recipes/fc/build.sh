#! /bin/sh

make \
  CC="${CC}" \
  CFLAGS="${CFLAGS} -std=c99"

install -d "${PREFIX}/bin"
install fc-virus "${PREFIX}/bin/"
