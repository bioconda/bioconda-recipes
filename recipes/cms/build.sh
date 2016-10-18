#!/bin/bash

make

cd $SRC_DIR/cms
mkdir -p $PREFIX/bin

combine_binaries="\
combine_scores_poppair \
combine_scores_multiplepops \
combine_scores_multiplepops_region \
write_xpehh_from_ihh \
"

model_binaries="\
calc_fst_deldaf \
bootstrap_freq_popstats_regions \
bootstrap_ld_popstats_regions \
bootstrap_fst_popstats_regions \
"

for i in $combine_binaries; do cp $SRC_DIR/cms/combine/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done

for i in $model_binaries; do cp $SRC_DIR/cms/model/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done


#top_scripts="\
#cms_modeller.py \
#likes_from_model.py \
#scans.py \
#composite.py \
#"
#for i in $top_scripts; do cp $SRC_DIR/cms/$i $PREFIX && chmod +x $PREFIX/$i; done

