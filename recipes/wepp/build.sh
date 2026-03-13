#!/bin/bash

# ---- Build ----
mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
	-DBOOST_ROOT="${PREFIX}" -Wno-dev -Wno-deprecated \
	--no-warn-unused-cli \
    -DTBB_DIR="${PREFIX}/lib/cmake/tbb" \
    "${CONFIG_ARGS}"

cmake --build build -j "${CPU_COUNT}"

# Install the WEPP binary to $PREFIX/bin
mkdir -p "${PREFIX}/bin"
install -v -m 0755 build/wepp "${PREFIX}/bin/wepp"

# Copy WEPP files to $PREFIX/WEPP
mkdir -p ${PREFIX}/WEPP
cp -rf "${SRC_DIR}"/* "${PREFIX}/WEPP"

# Remove the dirty build directory (avoids "cmake not found" crashes) and copy  the compiled binary we just built 
rm -rf "${PREFIX}/WEPP/build"
mkdir -p "${PREFIX}/WEPP/build"
cp build/wepp "${PREFIX}/WEPP/build/"
cp build/closest_peak_clustering "${PREFIX}/WEPP/build/"

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

# Creates a function 'snakemake' that injects the -s argument
ACTIVATE_DIR="${PREFIX}/etc/conda/activate.d"
DEACTIVATE_DIR="${PREFIX}/etc/conda/deactivate.d"
mkdir -p "${ACTIVATE_DIR}" "${DEACTIVATE_DIR}"

cat <<'EOF' > "${ACTIVATE_DIR}/wepp_activate.sh"
#!/bin/bash

run-wepp() {
        # Calls the snakemake with correct Snakefile
        command snakemake -s "$CONDA_PREFIX/WEPP/workflow/Snakefile" "$@"
}
# Want this command available in sub-shells/scripts
export -f run-wepp 2>/dev/null || true
EOF

# Removes the function when the user exits the environment
cat <<'EOF' > "${DEACTIVATE_DIR}/wepp_deactivate.sh"
#!/bin/bash
unset -f run-wepp
EOF

chmod +x "${ACTIVATE_DIR}/wepp_activate.sh"
chmod +x "${DEACTIVATE_DIR}/wepp_deactivate.sh"
