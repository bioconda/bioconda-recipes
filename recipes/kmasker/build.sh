#!/bin/bash
if [[ "$OSTYPE" == "darwin"* ]]; then #MacOS
	rm -rf ea-utils #EA-Utils does not build fine in osx, but fastq-stats does!
	git clone https://github.com/ExpressionAnalysis/ea-utils
	cd ea-utils/clipper
	CFLAGS="-I. -I${PREFIX}/include -L${PREFIX}/lib" PREFIX=${PREFIX} make fastq-stats
	cp fastq-stats ../../bin/
	cd ../../
	export CXXFLAGS_DEFAULT=${CXXFLAGS}
    export CXXFLAGS="${CXXFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
    export INSTALL_NAME_TOOL=${INSTALL_NAME_TOOL:-install_name_tool}
fi
scons -Q PREFIX=${PREFIX} install
