#!/usr/bin/env bash

# Set MKL environment variables
export MKLROOT=${PREFIX}
mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"


make clean && make MKLROOT=${PREFIX} AVX=0 && mv PCAone ${PREFIX}/bin/PCAone.x64
make clean && make MKLROOT=${PREFIX} AVX=1 && mv PCAone ${PREFIX}/bin/PCAone.avx2
export LDFLAGS="-Wl,--no-as-needed -L$PREFIX/lib"
echo "#!/usr/bin/env bash
PCAone=${PREFIX}/bin/PCAone.avx2
grep avx2 /proc/cpuinfo |grep fma &>/dev/null
[[ \$? != 0 ]] && PCAone=${PREFIX}/bin/PCAone.x64
exec \$PCAone \$@" >${PREFIX}/bin/PCAone && chmod +x ${PREFIX}/bin/PCAone


