#!/usr/bin/env bash

set -e

mkdir -p "$PREFIX/bin"
chmod u+x bin/*
cp -r bin/* "$PREFIX/bin"

cp -r EnsembleScripts "$PREFIX"

cp -r V4Scripts "$PREFIX"

cp -r configTemplates "$PREFIX"

for script in sipros_prepare_protein_database.py sipros_psm_tabulating.py sipros_ensemble_filtering.py sipros_peptides_assembling.py; do
    baseName=$(basename $script .py)
    sed -i '1i#!/usr/bin/env python\n' "$PREFIX/EnsembleScripts/$script"
    ln -s "$PREFIX/EnsembleScripts/$script" "$PREFIX/bin/EnsembleScripts_$baseName"
done

for script in sipros_peptides_filtering.py sipros_peptides_assembling.py ClusterSip.py; do
    baseName=$(basename $script .py)
    sed -i '1i#!/usr/bin/env python\n' "$PREFIX/V4Scripts/$script"
    ln -s "$PREFIX/V4Scripts/$script" "$PREFIX/bin/V4Scripts_$baseName"
done

for script in refineProteinFDR.R getSpectraCountInEachFT.R makeDBforLabelSearch.R getLabelPCTinEachFT.R; do
    baseName=$(basename $script .R)
    sed -i '1i#!/usr/bin/env Rscript\n' "$PREFIX/V4Scripts/$script"
    ln -s "$PREFIX/V4Scripts/$script" "$PREFIX/bin/V4Scripts_$baseName"
done

cp "$RECIPE_DIR"/Raxport.sh "$PREFIX/bin/Raxport"
cp "$RECIPE_DIR"/copyConfigTemplate.sh "$PREFIX/bin/copyConfigTemplate"
chmod u+x $PREFIX/bin/*