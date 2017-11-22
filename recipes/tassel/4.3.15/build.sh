BINARY_HOME=$PREFIX/bin
TASSEL_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Download TASSEL4 from its public repo
git clone git://git.code.sf.net/p/tassel/tassel4-standalone tassel4-standalone
cd tassel4-standalone
git checkout V$PKG_VERSION

# Copy source to the conda environment
mkdir -p $TASSEL_HOME
cp -R * $TASSEL_HOME/

# Fix shabang lines
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $TASSEL_HOME/*.pl

# Create wrapper script in bin to call TASSEL's launch scripts
cat >"${BINARY_HOME}/run_pipeline.sh" <<EOF
exec $CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/run_pipeline.pl "\$@"
EOF

cat >"${BINARY_HOME}/run_anything.sh" <<EOF
exec $CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/run_anything.pl "\$@"
EOF

cat >"${BINARY_HOME}/start_tassel.sh" <<EOF
exec $CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/start_tassel.pl "\$@"
EOF

chmod +x ${BINARY_HOME}/run_pipeline.sh
chmod +x ${BINARY_HOME}/run_anything.sh
chmod +x ${BINARY_HOME}/start_tassel.sh