#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/biotransformer.py $outdir/
ls -l $outdir
printf '#!/bin/bash\n' > $outdir/biotransformer
printf "cd ${outdir} \n" >> $outdir/biotransformer
printf 'python biotransformer.py "$@"\n' >> $outdir/biotransformer
ln -s $outdir/biotransformer $PREFIX/bin
chmod 0755 "${PREFIX}/bin/biotransformer"
