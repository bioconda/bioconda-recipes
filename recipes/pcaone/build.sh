#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# sed -i.bak '/-march=native/d' Makefile
# sed -i.bak '35 s/$/ -Wl,--no-as-needed/' Makefile
wget https://raw.githubusercontent.com/Zilong-Li/test/main/Makefile || curl -LO https://raw.githubusercontent.com/Zilong-Li/test/main/Makefile

if [ $(uname -s) == "Linux" ];then
  make clean && make MKLROOT=${PREFIX} AVX=0 && mv PCAone ${PREFIX}/bin/PCAone.x64
  make clean && make MKLROOT=${PREFIX} AVX=1 && mv PCAone ${PREFIX}/bin/PCAone.avx2
  echo "#!/usr/bin/env bash
PCAone=${PREFIX}/bin/PCAone.avx2
grep avx2 /proc/cpuinfo |grep fma &>/dev/null
[[ \$? != 0 ]] && PCAone=${PREFIX}/bin/PCAone.x64
exec \$PCAone \$@" >${PREFIX}/bin/PCAone && chmod +x ${PREFIX}/bin/PCAone

elif [ $(uname -s) == "Darwin" ];then
  make MKLROOT=${PREFIX}
  mv PCAone ${PREFIX}/bin/
fi
