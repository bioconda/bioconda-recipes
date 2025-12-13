#!/usr/bin/env bash
set -euxo pipefail

DEST_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${DEST_DIR}"

SOURCE_SUBDIR="excavator2"

find "${SOURCE_SUBDIR}" -name "*.so" -delete
find "${SOURCE_SUBDIR}" -name "*.o" -delete

cp -r "${SOURCE_SUBDIR}"/* "${DEST_DIR}/"

cd "${DEST_DIR}/lib/F77"

for lib_file in *.f; do
    echo "Compiling ${lib_file}..."
    R CMD SHLIB "${lib_file}"
done

cd -

chmod -R a+rX "${DEST_DIR}"

mkdir -p "${PREFIX}/bin"

for exe in EXCAVATORDataAnalysis.pl EXCAVATORDataPrepare.pl TargetPerla.pl; do
  chmod +x "${DEST_DIR}/${exe}"
  ln -s "${DEST_DIR}/${exe}" "${PREFIX}/bin/${exe}"
done
