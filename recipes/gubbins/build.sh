#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak "s|3.4.2|${PKG_VERSION}|" VERSION
sed -i.bak 's|find_packages|find_namespace_packages|' python/setup.py
rm -rf python/*.bak

if [[ "$target_platform" == osx-* ]]; then
    for toolname in "otool" "install_name_tool"; do
        tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname")
        mv "${tool}" "${tool}.bak"
        ln -sf "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
    done
fi

autoreconf -if
./configure --prefix="${PREFIX}" \
    --disable-option-checking --enable-silent-rules --disable-dependency-tracking \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS}" \
    PYTHON="${PYTHON}"

make -j"${CPU_COUNT}"
make install

cd python
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 --report record.txt -vvv
