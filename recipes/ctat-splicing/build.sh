cd bamsifter/htslib || exit 1
autoreconf --force --install --verbose
./configure
cd ../.. || exit 1

make
