#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p build
cd build

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export MPICXX="$PREFIX/bin"
export OMPI_MCA_mpi_show_handle_leaks=1
export share_dir="${PREFIX}/share/Ray-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${share_dir}"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile && rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile && rm -f *.bak
	;;
esac

make

"${STRIP}" "install-prefix/Ray"

cp -rf install-prefix/* "${share_dir}"

ln -sf "${share_dir}/Ray" "${PREFIX}/bin/"
