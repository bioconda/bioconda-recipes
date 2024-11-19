#!/bin/bash
set -eu

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${outdir}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
	-DBOOST_ROOT="${PREFIX}" "${CONFIG_ARGS}"

cmake --build build --target install -j "${CPU_COUNT}" -v

#cp -r bin lib libexec share $outdir
#sed -i.bak \
#    -e "s~scriptDir=.*~scriptDir='$outdir/bin'~" \
#    -e "s~workflowDir=.*~workflowDir='$outdir/lib/python'~" \
#    $outdir/bin/configure*.py
#sed -i.bak \
#    -e "s~scriptDir=.*~scriptDir='$outdir/bin'~" \
#    $outdir/bin/run*.bash
ln -sf $outdir/bin/config*.py $outdir/bin/run*.bash $PREFIX/bin
