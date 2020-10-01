set -x -e

mkdir -p "${PREFIX}/bin"

cd cluster_identifier/src
${GCC} -I"${BUILD_PREFIX}/include" -L"${BUILD_PREFIX}/lib" -o "${PREFIX}/bin/cluster_identifier" -lz -lpthread -llzma -lbz2 -lcurl -lcrypto -lhts cluster_identifier.c
