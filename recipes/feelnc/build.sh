#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/utils

sed -i.bak 's/#!\/usr\/bin\/perl -w/#!\/usr\/bin\/env perl/' scripts/*

cp scripts/* ${PREFIX}/bin/
cp utils/FEELnc_pipeline.sh ${PREFIX}/bin/
cp utils/* ${PREFIX}/utils/

# copy perl libraries
perl_version=$(perl -e 'print $^V');
perl_version=${perl_version:1}
cp lib/Bio/SeqFeature/* ${PREFIX}/lib/site_perl/${perl_version}/Bio/SeqFeature/
cp -r lib/Bio/DB/* ${PREFIX}/lib/site_perl/${perl_version}/Bio/DB/
cp lib/*pm ${PREFIX}/lib/site_perl/${perl_version}/

# create env files to export / unset FEELNCPATH environment variable needed by feelnc scripts
mkdir -p ${PREFIX}/etc/conda/activate.d/
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/feelnc-env.sh
export FEELNCPATH=${PREFIX}/
EOF

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/unset-feelnc-env.sh
unset FEELNCPATH
EOF

chmod a+x ${PREFIX}/etc/conda/activate.d/feelnc-env.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/unset-feelnc-env.sh
