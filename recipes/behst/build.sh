#!/bin/bash
INSTALLDIR="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"

mkdir -p $PREFIX/bin
mkdir -p $INSTALLDIR/{bin,test,results}

# project.sh hard-codes other helper scripts; make sure they're in the same dir
# too.
for fn in bin/*; do
    base=$(basename $fn)
    cp $fn $INSTALLDIR/bin
    chmod +x $INSTALLDIR/bin/$base
    ln -s $INSTALLDIR/bin/$base $PREFIX/bin/$base
done

cp $RECIPE_DIR/download_behst_data.sh $PREFIX/bin
chmod +x $PREFIX/bin/download_behst_data.sh
