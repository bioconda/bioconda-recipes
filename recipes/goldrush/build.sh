#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin

# Make wrapper script for goldrush
cp bin/goldrush ${PREFIX}/bin/goldrush.make
echo "#!/bin/bash" > ${PREFIX}/bin/goldrush
echo "make -rRf $(which goldrush.make)" >> ${PREFIX}/bin/goldrush
chmod 755 ${PREFIX}/bin/goldrush

# Build goldrush
meson --prefix ${PREFIX} build
cd build
ninja
ninja install
