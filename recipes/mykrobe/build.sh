#!/bin/bash
set -x

# specify zlib location https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include -fcommon"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="$PREFIX/include"
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

make MAXK=31
cp bin/mccortex31 ../src/mykrobe/cortex/
cd ../ || exit 1

"$PYTHON" -m pip install . -vv
mykrobe panels update_metadata
mykrobe panels update_species all
