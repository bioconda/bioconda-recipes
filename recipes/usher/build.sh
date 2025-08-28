#!/bin/bash
set -ex

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

mkdir -p build
pushd build

if [[ "$(uname -m)" == "arm64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
elif [[ "$(uname -m)" == "aarch64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
else
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
fi

cmake -S .. -B . -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBOOST_ROOT="${PREFIX}" -Wno-dev -Wno-deprecated \
	--no-warn-unused-cli \
	"${EXTRA_ARGS}" \
	"${CONFIG_ARGS}"

if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "x86_64" ]]; then
	# omit ripples-fast due to problems building on Mac
	ninja -j"${CPU_COUNT}" usher matUtils matOptimize usher-sampled ripples
	cat > ripples-fast <<EOF
#!/bin/bash
# This is a placeholder for the program ripples-fast on Mac where the build is currently failing.
# This is only a temporary workaround until we can fix ripples-fast, so that the rest of the
# programs in the usher package are not held back.
echo ""
echo "Sorry, ripples-fast is temporarily unavailable from bioconda for Mac."
echo "Please chime in on https://github.com/yatisht/usher/issues/310 if this inconveniences you."
echo ""
EOF
	chmod a+x ripples-fast
else
	cmake --build . --clean-first --target install -j "${CPU_COUNT}"
fi

if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "x86_64" ]]; then
	install -v -m 755 usher* mat* ripples* "${PREFIX}/bin"
else
	install -v -m 755 usher* mat* transpose* ripples* compareVCF check_samples_place "${PREFIX}/bin"
fi

popd
