#!/bin/bash
set -x

# specify zlib location https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CC="${CC} -fcommon -lstdc++"
export CXX="${CC} -fcommon"

# download phelim's fork of mccortex
MCCORTEX_DIR=mccortex
MCCORTEX_GIT="https://github.com/phelimb/mccortex"
mkdir "$MCCORTEX_DIR"
git clone --recursive -b geno_kmer_count "$MCCORTEX_GIT" "$MCCORTEX_DIR"
cd "$MCCORTEX_DIR" || exit 1

# comment this out as it overrides my LDFLAGS variable
sed -i.bak 's/LDFLAGS  =/#LDFLAGS  =/' libs/htslib/Makefile
# gcc is hard-coded into Makefile. Comment out to use the conda gcc
sed -i.bak 's/^CC/#CC/' libs/htslib/Makefile

# point some -lz calls to zlib location
for make_file in libs/string_buffer/Makefile $(find libs/seq_file -name Makefile) $(find libs/seq-align -name Makefile) Makefile; do
    sed -i.bak 's/-lz/-lz $(LDFLAGS)/' "$make_file"
done

if [[ $(arch) != "x86_64" ]]; then
    sed -i.bak 's/-m64//' Makefile
fi

make MAXK=31 -j"${CPU_COUNT}"
cp -f bin/mccortex31 ../src/mykrobe/cortex/
cd ../ || exit 1

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -rf *.bak

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
mykrobe panels update_metadata
mykrobe panels update_species all
