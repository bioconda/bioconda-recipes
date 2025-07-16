#!/bin/bash
if [[ ${target_platform} == "linux-aarch64" ]];then
  sed -i.bak '19s/#include <emmintrin.h>/\/\//' src/zinm.h
fi

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
mkdir -p "${PREFIX}/bin"
cp zerone "${PREFIX}/bin/"
