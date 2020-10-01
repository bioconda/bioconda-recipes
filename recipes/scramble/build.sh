set -x -e

mkdir -p "${PREFIX}/bin"

cd cluster_identifier/src
${GCC} $CFLAGS $LDFLAGS -o "${PREFIX}/bin/cluster_identifier" cluster_identifier.c -lz -lpthread -llzma -lbz2 -lcurl -lcrypto -lhts
