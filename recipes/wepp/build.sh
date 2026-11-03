#!/bin/bash

# ---- Build ----
mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# x86_64 intentionally keeps the conda-forge default (-march=nocona -mtune=haswell).
# Raising it to x86-64-v3 lets the compiler emit AVX2/FMA/BMI, which SIGILLs on any
# pre-Haswell host, including the Ivy Bridge Xeons still widespread on HPC clusters.
case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
	export CONFIG_ARGS=""
fi

# WEPP 0.1.6.1's release tarball is packed on macOS; the ._WEPP AppleDouble
# file defeats conda-build's single-top-level-dir flattening on Linux, so the
# tree lands at $SRC_DIR/WEPP instead of $SRC_DIR. Normalize it.
if [[ -f "${SRC_DIR}/WEPP/CMakeLists.txt" ]]; then
    cd "${SRC_DIR}/WEPP"
	cp -f LICENSE "${SRC_DIR}/"
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBOOST_ROOT="${PREFIX}" \
	-DTBB_DIR="${PREFIX}/lib/cmake/tbb" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
    "${CONFIG_ARGS}"

cmake --build build --clean-first -j "${CPU_COUNT}"

# Install the WEPP binary to $PREFIX/bin
install -v -m 0755 build/wepp "${PREFIX}/bin"

# Copy WEPP files to $PREFIX/WEPP
mkdir -p "${PREFIX}/WEPP"
if [[ -f "${SRC_DIR}/WEPP/CMakeLists.txt" ]]; then
	cp -rf "${SRC_DIR}/WEPP/src" "${SRC_DIR}/WEPP/config" "${SRC_DIR}/WEPP/workflow" "${SRC_DIR}/WEPP/primers" "${SRC_DIR}/WEPP/LICENSE" "${SRC_DIR}/WEPP/parsimony.proto" "${SRC_DIR}/WEPP/sam.proto" "${PREFIX}/WEPP/"
else
	cp -rf "${SRC_DIR}/src" "${SRC_DIR}/config" "${SRC_DIR}/workflow" "${SRC_DIR}/primers" "${SRC_DIR}/LICENSE" "${SRC_DIR}/parsimony.proto" "${SRC_DIR}/sam.proto" "${PREFIX}/WEPP/"
fi

# Copy the compiled binary we just built 
mkdir -p "${PREFIX}/WEPP/build"
cp -f build/wepp "${PREFIX}/WEPP/build/"
cp -f build/closest_peak_clustering "${PREFIX}/WEPP/build/"

# This satisfies Snakemake's output requirement without running bad commands.
cat <<'EOF' > "${PREFIX}/WEPP/build/Makefile"
all:
	@echo "WEPP is pre-compiled. Skipping build."
install:
	@echo "Nothing to install."
clean:
	@echo "Nothing to clean."
EOF

# Set Source Code date to the Past (Year 2000)
find "${PREFIX}/WEPP/src" -exec touch -t 200001010000 {} +
# Set Binary/Makefile date to Now
touch "${PREFIX}/WEPP/build/Makefile"
touch "${PREFIX}/WEPP/build/wepp"

# Create the wrapper script
cat <<WRAPPER > "${PREFIX}/bin/run-wepp"
#!/bin/bash
exec snakemake -s "\${CONDA_PREFIX}/WEPP/workflow/Snakefile" "\$@"
WRAPPER

# Make the wrapper executable
chmod +x "${PREFIX}/bin/run-wepp"
