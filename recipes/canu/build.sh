#!/bin/bash

# fail on all errors
set -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/lib/perl5/site_perl/canu"
mkdir -p "${PREFIX}/share/java/classes"

cp -rfv src/pipelines/canu/*.pm "${PREFIX}/lib/perl5/site_perl/canu"
cp -rfv src/mhap/mhap-2.1.3.jar "${PREFIX}/share/java/classes"

cd src
make CC="${CC} -O3" CXX="${CXX} -O3 -I${PREFIX}/include" -j"${CPU_COUNT}"

cp -rfv ${SRC_DIR}/build/lib/libcanu.a "${PREFIX}/lib"
cd ../build/bin
install -v -m 0755 canu canu-time draw-tig canu.defaults dumpBlob ovStoreBuild ovStoreConfig ovStoreBucketizer \
	ovStoreSorter ovStoreIndexer ovStoreDump ovStoreStats sqStoreCreate sqStoreDumpFASTQ sqStoreDumpMetaData \
	tgStoreCompress tgStoreDump tgStoreLoad tgTigDisplay loadCorrectedReads loadTrimmedReads loadErates \
	seqrequester meryl overlapInCore overlapInCorePartition overlapConvert overlapImport overlapPair \
	edalign mhapConvert mmapConvert filterCorrectionOverlaps generateCorrectionLayouts filterCorrectionLayouts \
	falconsense errorEstimate splitHaplotype trimReads splitReads mergeRanges overlapAlign findErrors \
	fixErrors correctOverlaps bogart layoutReads utgcns layoutToPackage alignGFA "${PREFIX}/bin"
