# Helixer with post-processing via AUGUSTUS

## Additional Dependencies

This requires AUGUSTUS and all its dependencies, see: 
https://github.com/Gaius-Augustus/Augustus

## When to use or not
For _de novo_ prediction of primary gene models helixer + AUGUSTUS 
does not have _quite_ the same raw accuracy as running 
helixer + helixer_post_bin (as done when running Helixer.py),
on species we've checked so far. If this is your use-case, we
recommend using helixer + helixer_post_bin (e.g. via Helixer.py
as described in the main README.md); it's also substantially faster.

However, helixer + AUGUSTUS _does_ provide alternative transcripts, 
which the other does not, and helixer + AUGUSTUS _should_ be extensible 
for integration with any extrinsic data sources that AUGUSTUS supports.

## The process

First, generate Helixer predictions for the genome in question 
(using the same example data as the main readme).

```
# this exactly matches the 'example broken into individual steps' from the README.md
fasta2h5.py --species Arabidopsis_lyrata --h5-output-path Arabidopsis_lyrata.h5 --fasta-path Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa
helixer/prediction/HybridModel.py --load-model-path models/land_plant.h5 --test-data Arabidopsis_lyrata.h5 --overlap --val-test-batch-size 32 -v
```

Second, convert these predictions into hints
```
python scripts/predictions2hints.py -p predictions.h5 -d Arabidopsis_lyrata.h5 -o Arabidopsis_lyrata_helixer_hints.gff3
```

Third, get extrinsic config setup for Helixer-style hints. Bonus and penalty weighting 
has not been optimized, and it may be worth it to adjust these. 
To combine with any other hint sources, 
the extrinsic cfg file will need to be updated according to 
AUGUSTUS documentation.

```
wget https://raw.githubusercontent.com/weberlab-hhu/helixer_scratch/master/method_comp/running_augustus/cgp.extrinsic.cfg
```

Fourth, run AUGUSTUS
```
# adjust the following to the best/closest AUGUSTUS species model 
# that you have available for your target species
augustus_sp=arabidopsis
  
# run augustus
augustus --species=$augustus_sp Arabidopsis_lyrata.v.1.0.dna.chromosome.8.fa --softmasking=1 \
    --extrinsicCfgFile=cgp.extrinsic.cfg --hintsfile=Arabidopsis_lyrata_helixer_hints.gff3 \
    --gff3=on --UTR=on > Arabidopsis_lyrata_chromosome8_helixer_augustus.gff3
# depending on genome size, this may take a long time (from several hours to days)
```
