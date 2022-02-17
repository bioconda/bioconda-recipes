#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME
mkdir -p $outdir
mkdir -p $outdir/module
mkdir -p $PREFIX/bin
cp -R * $outdir/
cp $RECIPE_DIR/effectivet3.py $outdir/effectivet3
ls -l $outdir
ln -s $outdir/effectivet3 $PREFIX/bin
chmod 0755 "${PREFIX}/bin/effectivet3"

# Download the models too, put them in module sub-folder.

# Original URL http://effectors.csb.univie.ac.at/sites/eff/files/others/TTSS_ANIMAL-1.0.1.jar
curl -o TTSS_ANIMAL-1.0.1.jar https://depot.galaxyproject.org/software/TTSS_ANIMAL/TTSS_ANIMAL_1.0.1_src_all.jar
sha256sum TTSS_ANIMAL-1.0.1.jar | grep 3d9cd8e805387d2dfa855076b3d5f7f97334aa612288075111329fb036c94e34
cp TTSS_ANIMAL-1.0.1.jar $outdir/module/

# Original URL http://effectors.csb.univie.ac.at/sites/eff/files/others/TTSS_PLANT-1.0.1.jar
curl -o TTSS_PLANT-1.0.1.jar https://depot.galaxyproject.org/software/TTSS_PLANT/TTSS_PLANT_1.0.1_src_all.jar
sha256sum TTSS_PLANT-1.0.1.jar | grep 593f0052ace030c2fa16cf336f3916a21bc2addbaefdfa149b084b1425e42a13
cp TTSS_PLANT-1.0.1.jar $outdir/module/

# Original URL http://effectors.csb.univie.ac.at/sites/eff/files/others/TTSS_STD-1.0.1.jar
curl -o TTSS_STD-1.0.1.jar https://depot.galaxyproject.org/software/TTSS_STD/TTSS_STD_1.0.1_src_all.jar
sha256sum TTSS_STD-1.0.1.jar | grep 865809e5ead6d8bb038e854ccaebc7c102b72738ff3557553af9b9ac8e529336
cp TTSS_STD-1.0.1.jar $outdir/module/

# Original URL http://effectors.csb.univie.ac.at/sites/eff/files/others/TTSS_STD-2.0.2.jar
curl -o TTSS_STD-2.0.2.jar https://depot.galaxyproject.org/software/TTSS_STD/TTSS_STD_2.0.2_src_all.jar
sha256sum TTSS_STD-2.0.2.jar | grep 860c6e3680fa1f3c6ac2362605205af4cdd9a1caefee59fdbd37d1453c9bad44
cp TTSS_STD-2.0.2.jar $outdir/module/
