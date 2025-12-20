#!/bin/bash

# ---- Build ----
mkdir -p "${PREFIX}/bin"
cp -rf ${RECIPE_DIR}/CMakeLists.txt $SRC_DIR/CMakeLists.txt

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

# Copy WEPP files to $PREFIX/WEPP
mkdir -p ${PREFIX}/WEPP
cp -rf "${SRC_DIR}"/* "${PREFIX}/WEPP"
# Removes build directory to allow users to locally build WEPP based on their OS
rm -rf "${PREFIX}/WEPP/build"

# Creates a function 'snakemake' that injects the -s argument
ACTIVATE_DIR="${PREFIX}/etc/conda/activate.d"
DEACTIVATE_DIR="${PREFIX}/etc/conda/deactivate.d"
mkdir -p "${ACTIVATE_DIR}" "${DEACTIVATE_DIR}"

cat <<'EOF' > "${ACTIVATE_DIR}/wepp_activate.sh"
#!/bin/bash

# Store the original snakemake command location if needed, or just use 'command'
snakemake() {
    # Check if the user manually provided -s or --snakefile
    if [[ "$*" == *"-s "* ]] || [[ "$*" == *"--snakefile "* ]]; then
        command snakemake "$@"
    else
        # Inject the WEPP Snakefile path
        command snakemake -s "$CONDA_PREFIX/WEPP/workflow/Snakefile" "$@"
    fi
}
export -f snakemake 2>/dev/null || true
EOF

# Removes the function when the user exits the environment
cat <<'EOF' > "${DEACTIVATE_DIR}/wepp_deactivate.sh"
#!/bin/bash
unset -f snakemake
EOF

chmod +x "${ACTIVATE_DIR}/wepp_activate.sh"
chmod +x "${DEACTIVATE_DIR}/wepp_deactivate.sh"
