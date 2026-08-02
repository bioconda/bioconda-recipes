#!/bin/bash
set -e
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"

if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -m)" == "x86_64"]]; then
	sed -i.bak "s|-O3|-O3 -D_LIBCPP_DISABLE_AVAILABILITY|" Makefile
	rm -f *.bak
fi

ln -sf ${CXX} ${PREFIX}/bin/g++

# If you are making a g++ symlink:
#mkdir -p ./mybin
#ln -s "$(command -v $CXX)" ./mybin/g++
#export PATH="$(pwd)/mybin:$PATH"

# Now build and install
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
