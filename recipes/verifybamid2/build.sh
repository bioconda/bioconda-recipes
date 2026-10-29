#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"
TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

CONFIG_ARGS=()
if [[ `uname -s` == "Darwin" ]]; then
	CONFIG_ARGS+=(-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER)
	# Force CMake to archive static libraries with the conda cctools ar/ranlib
	# rather than the compiler-bundled llvm tools. The llvm-ranlib in the osx
	# build environment is broken (it aborts trying to load @rpath/libLLVM.*.dylib),
	# which breaks archiving of the C++-only libVcf library. cctools ranlib works
	# fine -- it is what CMAKE_RANLIB already resolves to for the mixed-language
	# libstatgen, which archives successfully. Guarded so that if the conda
	# toolchain ever stops exporting AR/RANLIB we fall back to CMake's defaults
	# rather than failing under `set -u`.
	if [[ -n "${AR:-}" && -n "${RANLIB:-}" ]]; then
		CONFIG_ARGS+=(-DCMAKE_C_COMPILER_AR="${AR}" -DCMAKE_CXX_COMPILER_AR="${AR}")
		CONFIG_ARGS+=(-DCMAKE_C_COMPILER_RANLIB="${RANLIB}" -DCMAKE_CXX_COMPILER_RANLIB="${RANLIB}")
	fi
fi

sed -i.bak "s|2.0.1|${PKG_VERSION}|" main.cpp
rm -f *.bak

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS[@]+"${CONFIG_ARGS[@]}"}"

ninja -C build -j"${CPU_COUNT}"

install -v -m 0755 bin/VerifyBamID "$TGT"
mkdir -p $TGT/resource $TGT/resource/exome
mv resource/1000g* $TGT/resource
mv resource/hgdp* $TGT/resource
mv resource/exome/1000g* $TGT/resource/exome
cp -f $RECIPE_DIR/verifybamid2.sh $TGT/verifybamid2
chmod a+x $TGT/verifybamid2
ln -s $TGT/verifybamid2 $PREFIX/bin/verifybamid2
