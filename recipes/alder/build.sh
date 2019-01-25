#!/usr/bin/env bash

make CFLAGS="-Wno-unused-comparison -Wno-return-type -I${PREFIX}/include -Iadmixtools_src/nicksrc" LDFLAGS="-L${PREFIX}/lib -Ladmixtools_src/nicksrc"

mkdir -p ${PREFIX}/bin
cp alder ${PREFIX}/bin/
