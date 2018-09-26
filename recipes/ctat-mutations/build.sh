#!/bin/bash
ctat_mutations_DIR_NAME="$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
ctat_mutations_INSTALL_PATH="$PREFIX/share/$ctat_mutations_DIR_NAME"
share_path="$PREFIX/share"
# Make the install directory and move the ctat-mutations files to that location.
mkdir -p $PREFIX/bin
mkdir -p $ctat_mutations_INSTALL_PATH
#copy to INSTALL_PATH
cd $SRC_DIR
cp -R ctat_mutations PyLib mutation_lib_prep plugins src testing LICENSE.txt README.md $ctat_mutations_INSTALL_PATH
#change permissions on ctat_mutations
chmod a+x $ctat_mutations_INSTALL_PATH/ctat_mutations
cd $PREFIX/bin
ACTUAL_GATK=$(python -c "\
import glob
print glob.glob(\"$share_path/gatk4-*\")
")
GATK_HOME=$(python -c "\
print \"/\".join(\"$ACTUAL_GATK\".split(\"/\")[0:-1])
")
ACTUAL_PICARD=$(python -c "\
import glob
print glob.glob(\"$share_path/picard-*\")
")
PICARD_HOME=$(python -c "\
print \"/\".join(\"$ACTUAL_PICARD\".split(\"/\")[0:-1])
")
echo '#!/bin/bash' > ctat_mutations
echo "export PICARD_HOME=$PICARD_HOME" >> ctat_mutations 
echo "export GATK_HOME=$GATK_HOME" >> ctat_mutations
echo "$ctat_mutations_INSTALL_PATH/ctat_mutations \$@" >> ctat_mutations
chmod a+x ctat_mutations
