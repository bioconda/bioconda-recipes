TASSEL_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Download TASSEL4 from its public repo
git clone git://git.code.sf.net/p/tassel/tassel4-standalone tassel-tassel4-standalone
cd tassel-tassel4-standalone
git checkout V$PKG_VERSION

# Copy source to the conda environment
mkdir -p $TASSEL_HOME
cp -R * $TASSEL_HOME/

# Fix shabang lines
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $TASSEL_HOME/*.pl

# Create custom (de)activate scripts to append or remove TASSEL's top level directory to the PATH.  Its wrapper
# programs have to be invoked in its top level directory to detect is runtime libraries correctly
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >"${PREFIX}/etc/conda/activate.d/tassel-activate.sh" <<EOF
export PATH="\$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM:\$PATH"
EOF
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >"${PREFIX}/etc/conda/deactivate.d/tassel-deactivate.sh" <<EOF
export PATH="\$CONDA_PATH_BACKUP"
EOF