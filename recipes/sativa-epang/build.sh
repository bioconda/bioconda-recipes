#!/bin/bash
set -euo pipefail

# RAxML 8.2.3, from the tarball SATIVA ships, built as SATIVA's own install.sh builds it and
# as the `sativa` recipe does: SSE3 and plain PTHREADS always, AVX and AVX2 as well, with
# raxml/run_raxml.sh picking between them from /proc/cpuinfo at run time. The Makefile strips
# -march=native, so none of the four is tuned to the build machine. All four are shipped
# because the choice is not neutral: the vectorised likelihood does not associate the same
# way, and an SSE3 build and an AVX2 build can produce reference trees differing in the last
# digits.
export USE_AVX=yes
export USE_AVX2=yes
make -C raxml CC="${CC}"

# Under share/ rather than bin/, so that epac/ and raxml/ do not land on PATH.
SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${SHARE}" "${PREFIX}/bin"

cp -R epac epa_trainer.py epa_classifier.py sativa.py sativa.cfg raxml "${SHARE}/"

# The bundled example, at a path that does not carry the version, so the recipe's test can
# name it. It has to ship inside the package: the container test runs with the package
# installed and nothing else, no recipe directory and no source tree.
mkdir -p "${PREFIX}/share/${PKG_NAME}"
cp -R example "${PREFIX}/share/${PKG_NAME}/example"
# No build leftovers, and no temp directory: an installed SATIVA writes its temporary files
# under the output directory (see check_args in sativa.py), not next to its code.
rm -rf "${SHARE}"/raxml/builddir.* "${SHARE}"/raxml/*.stamp "${SHARE}"/raxml/*.tar.gz
find "${SHARE}" -name '__pycache__' -type d -prune -exec rm -rf {} +
chmod +x "${SHARE}/sativa.py" "${SHARE}/raxml/run_raxml.sh" "${SHARE}"/raxml/raxmlHPC8-*

# `sativa-epang`, not `sativa.py`: the `sativa` package installs sativa.py into bin, and two
# packages must not claim the same path.
cat > "${PREFIX}/bin/sativa-epang" <<EOF
#!/bin/bash
exec "${PREFIX}/bin/python" "${SHARE}/sativa.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/sativa-epang"
