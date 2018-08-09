#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/utils

sed -i.bak 's/#!\/usr\/bin\/perl -w/#!\/usr\/bin\/env perl/' scripts/*

cp scripts/* ${PREFIX}/bin/
cp utils/FEELnc_pipeline.sh ${PREFIX}/bin/
cp utils/* ${PREFIX}/utils/

# copy perl libraries
cp lib/Bio/SeqFeature/* ${PREFIX}/lib/perl5/site_perl/*/Bio/SeqFeature/
cp -r lib/Bio/DB/* ${PREFIX}/lib/perl5/site_perl/*/Bio/DB/
cp lib/*pm ${PREFIX}/lib/perl5/site_perl/*/

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
