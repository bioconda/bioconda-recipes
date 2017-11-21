BINARY_HOME=$PREFIX/bin
TASSEL_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Copy source to bin
mkdir -p $BINARY_HOME
mkdir -p $TASSEL_HOME
cp -R $SRC_DIR/* $TASSEL_HOME/

# Fix shabang lines
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $TASSEL_HOME/*.pl

# Create wrapper script in bin to call TASSEL's launch scripts
cat >"${BINARY_HOME}/run_pipeline.sh" <<EOF
exec \$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/run_pipeline.pl "\$@"
EOF

cat >"${BINARY_HOME}/run_anything.sh" <<EOF
exec \$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/run_anything.pl "\$@"
EOF

cat >"${BINARY_HOME}/start_tassel.sh" <<EOF
exec \$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/start_tassel.pl "\$@"
EOF

chmod +x ${BINARY_HOME}/run_pipeline.sh
chmod +x ${BINARY_HOME}/run_anything.sh
chmod +x ${BINARY_HOME}/start_tassel.sh