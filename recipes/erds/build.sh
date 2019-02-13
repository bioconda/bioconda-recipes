#!/bin/bash

set -eu -o pipefail
set -x

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
bindir=${PREFIX}/bin

mkdir -p ${outdir}
mkdir -p ${bindir}

pushd hmm; make; popd
pushd phmm; make; popd
rm -rf software

cp -r * ${outdir}/
sed -i -e 's/\/perl/\/env perl/' ${outdir}/*.pl

cat <<EOF >${bindir}/erds_pipeline
#!/bin/bash

set -eu -o pipefail
export LC_ALL=en_US.UTF-8

perl ${outdir}/erds_pipeline.pl \$@
EOF

cat ${bindir}/erds_pipeline

chmod +x ${bindir}/erds_pipeline
