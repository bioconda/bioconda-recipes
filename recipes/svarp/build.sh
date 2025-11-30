#!/bin/bash
set -ex

cd "$SRC_DIR"

# Eğer g++ yoksa, conda'nın CXX derleyicisini çağıran bir wrapper oluştur
echo "CXX is: ${CXX:-'(not set)'}"
if ! command -v g++ >/dev/null 2>&1; then
    echo "No system g++ found, creating wrapper that calls \$CXX"
    mkdir -p "${BUILD_PREFIX}/bin"

    cat << 'EOF' > "${BUILD_PREFIX}/bin/g++"
#!/bin/bash
# Wrapper used in bioconda build: forward to $CXX from env
if [ -z "${CXX}" ]; then
    echo "Error: CXX is not set but g++ wrapper was called." >&2
    exit 1
fi
exec "${CXX}" "$@"
EOF

    chmod +x "${BUILD_PREFIX}/bin/g++"
    export PATH="${BUILD_PREFIX}/bin:${PATH}"
fi

make clean

echo "PREFIX is $PREFIX"
echo "Listing headers under $PREFIX/include:"
ls -R "$PREFIX/include"

# Conda kütüphanelerini kullanarak derle
make USE_CONDA=1 PREFIX="$PREFIX" -j"${CPU_COUNT}"

# Binary'i install et
mkdir -p "$PREFIX/bin"
cp build/svarp "$PREFIX/bin/"


