set -x -e

mkdir -p "${PREFIX}/bin"

$GCC $CFLAGS $LDFLAGS -o "${PREFIX}/bin/cluster_identifier" "${SRC_DIR}/cluster_identifier/src/cluster_identifier.c" -lz -lpthread -llzma -lbz2 -lcurl -lcrypto -lhts

cp -R "${SRC_DIR}/cluster_analysis" "${PREFIX}"
cp "${RECIPE_DIR}/scramble.sh" "${PREFIX}/bin"
