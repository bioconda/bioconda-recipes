#!/bin/bash

set -ex

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/annotation"

cd src
if [[ `uname` = "Darwin" ]]; then
	MAKEFILE=Makefile.MacOS
else
	MAKEFILE=Makefile.Linux
fi

if [[ $(uname -m) == "aarch64" ]]; then
	sed -i.bak 's/-mtune=core2//' ${MAKEFILE}
	sed -i.bak 's/-mtune=core2//' ./longread-one/Makefile
	rm -rf ./*.bak
	rm -rf ./longread-one/*.bak
fi

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export C="${CC}"

make -f "${MAKEFILE}" CC_EXEC="${C} -L${PREFIX}/lib -fcommon" -j"${CPU_COUNT}"

cd ..
install -v -m 0755 bin/utilities/flattenGTF bin/utilities/genRandomReads \
	bin/utilities/propmapped bin/utilities/qualityScores \
	bin/utilities/removeDup bin/utilities/repair \
	bin/utilities/subread-fullscan "${PREFIX}/bin"
rm -rf bin/utilities

install -v -m 0755 bin/exactSNP bin/featureCounts bin/subindel bin/subjunc \
	bin/sublong bin/subread-align bin/subread-buildindex "${PREFIX}/bin"
cp -rf annotation/* "${PREFIX}/annotation"

# add read permissions to LICENSE
chmod a+r LICENSE
