#!/usr/bin/env bash
set -euxo pipefail

DEST_DIR="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${DEST_DIR}"
SOURCE_SUBDIR="excavator2"

mkdir -p ~/.R

# Expand environment variables explicitly for macOS
cat <<EOF > ~/.R/Makevars
F77 = ${FC}
FC = ${FC}
FFLAGS = ${FFLAGS} -std=legacy -ffixed-line-length-none -w
FLIBS = ${LDFLAGS} -lgfortran -lquadmath
LDFLAGS = ${LDFLAGS}
SHLIB_LDFLAGS = ${LDFLAGS}
SHLIB_LIBADD = -lgfortran -lquadmath
EOF

find "${SOURCE_SUBDIR}" -name "*.so" -delete
find "${SOURCE_SUBDIR}" -name "*.o" -delete

cp -r "${SOURCE_SUBDIR}"/* "${DEST_DIR}/"

cd "${DEST_DIR}/lib/F77"
# compile libs
for lib_file in *.f; do
    echo "Compiling ${lib_file}..."
    # Use explicit environment variables for R CMD SHLIB
    R CMD SHLIB "${lib_file}" \
        F77="${FC}" \
        FC="${FC}" \
        FFLAGS="${FFLAGS} -std=legacy -ffixed-line-length-none -w" \
        LDFLAGS="${LDFLAGS}" \
        FLIBS="${LDFLAGS} -lgfortran -lquadmath"
done
cd -

chmod -R a+rX "${DEST_DIR}"
mkdir -p "${PREFIX}/bin"
for exe in EXCAVATORDataAnalysis.pl EXCAVATORDataPrepare.pl TargetPerla.pl; do
  chmod +x "${DEST_DIR}/${exe}"
  ln -s "${DEST_DIR}/${exe}" "${PREFIX}/bin/${exe}"
done
