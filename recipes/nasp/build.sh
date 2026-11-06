#!/bin/bash
set -euo pipefail

export CGO_ENABLED=0
pushd nasp/nasptool
go build -mod=readonly -trimpath -o ../nasptool_linux_64
popd

"$PYTHON" -m pip install --no-deps --no-build-isolation --ignore-installed --no-cache-dir -vvv .

# Expose dependency filenames expected by NASP; no application code change.
mkdir -p "$PREFIX/bin"

# Relative links are relocatable and owned/unlinked by Conda. Exact JAR package
# builds are runtime dependencies because their versioned directories are used.
ln -s ../opt/gatk-3.8/GenomeAnalysisTK.jar "$PREFIX/bin/GenomeAnalysisTK.jar"
ln -s ../share/picard-2.27.5-0/picard.jar "$PREFIX/bin/picard.jar"
ln -s ../share/varscan-2.4.6-0/VarScan.jar "$PREFIX/bin/VarScan.jar"
ln -s ../share/trimmomatic-0.40-0/trimmomatic.jar "$PREFIX/bin/trimmomatic.jar"
ln -s snap-aligner "$PREFIX/bin/snap_aligner"

for name in GenomeAnalysisTK.jar picard.jar VarScan.jar trimmomatic.jar snap_aligner; do
    test -r "$PREFIX/bin/$name"
done
test -x "$PREFIX/bin/snap_aligner"
