set -e

mkdir -p "$PREFIX/bin"
chmod u+x bin/*
cp -r bin/* "$PREFIX/bin"

cp -r EnsembleScripts "$PREFIX"
cp -r V4Scripts "$PREFIX"

cp -r configTemplates "$PREFIX"

cp $RECIPE_DIR/Raxport.sh "$PREFIX/bin/Raxport"
chmod +x "$PREFIX/bin/Raxport"

ln -s "$PREFIX"/EnsembleScripts/sipros_psm_tabulating.py "$PREFIX"/bin/sipros_psm_tabulating.py 
ln -s "$PREFIX"/V4Scripts/sipros_peptides_filtering.py "$PREFIX"/bin/sipros_peptides_filtering.py
