#!/bin/bash

set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

DEFAULT_LINUX_VERSION="cos7"
# * k8 is only compatible with Node.js v18.x, not more recent node versions
# * node-18.19.x can be compiled on CentOS 7, but not on macOS with clang
# * node-18.20.x can be compiled on MacOS but not on CentOS 7 because it
#   includes an updated c-ares library which is incompatible with glibc on CentOS 7
if [[ "$(uname)" == "Darwin" ]]; then
	NODE_VERSION="18.20.5"
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
else
	NODE_VERSION="18.19.1"
fi

case $(uname -m) in
	x86_64)
		THREADS="-j2"
		;;
	*)
		THREADS="-j3"
		;;
esac

wget -O- https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz | tar -zxf -
pushd node-v${NODE_VERSION}

# Workaround the following error that happens only on Azure build for Linux x86_64
# 2024-03-19T13:32:27.9240276Z 13:32:25 [32mBIOCONDA INFO[0m (OUT) ../src/debug_utils.cc:479:11: error: ignoring return value of 'size_t fwrite(const void*, size_t, size_t, FILE*)' declared with attribute 'warn_unused_result' [-Werror=unused-result][0m
# 2024-03-19T13:32:27.9240731Z 13:32:25 [32mBIOCONDA INFO[0m (OUT)   479 |     fwrite(str.data(), str.size(), 1, file);[0m
# 2024-03-19T13:32:27.9241079Z 13:32:25 [32mBIOCONDA INFO[0m (OUT)       |     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[0m
# 2024-03-19T13:32:27.9241412Z 13:32:27 [32mBIOCONDA INFO[0m (OUT) cc1plus: some warnings being treated as errors[0m
patch -p0 < ${RECIPE_DIR}/nodejs-x86_64.patch

# The provided configure script is a sh/python hybrid which boils down to one line of Python
python -c "import configure" --without-node-snapshot --without-etw --without-npm --without-inspector --without-dtrace
make "${THREADS}"
popd

# make it possible to set conda build's CXXFLAGS and point to the Node sources
sed -i.bak 's/CXXFLAGS=/CXXFLAGS?=/' Makefile
sed -i.bak 's/NODE_SRC=/NODE_SRC?=/' Makefile
sed -i.bak 's/LIBS=/LIBS?=/' Makefile
rm -rf *.bak

# Then compile k8
NODE_SRC="node-v${NODE_VERSION}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -std=c++17 -g -O3 -Wall" LIBS="${LDFLAGS} -pthread" make -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 k8 "${PREFIX}/bin"
