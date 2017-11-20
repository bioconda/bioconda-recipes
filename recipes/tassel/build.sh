BINARY_HOME=$PREFIX/bin
TASSEL_HOME=$PREFIX/opt/tassel

# Copy source to bin
mkdir -p $BINARY_HOME
mkdir -p $TASSEL_HOME
cp -R $SRC_DIR/* $TASSEL_HOME/

# Fix shabang lines
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $TASSEL_HOME/*.pl

# Create custome (de)activate scripts to append or remove TASSEL's top level directory to the PATH
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >"${PREFIX}/etc/conda/activate.d/tassel-activate.sh" <<EOF
export PATH="\$CONDA_PREFIX/opt/tassel:\$PATH"
EOF
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >"${PREFIX}/etc/conda/deactivate.d/tassel-deactivate.sh" <<EOF
export ARBHOME="\$CONDA_PATH_BACKUP"
EOF