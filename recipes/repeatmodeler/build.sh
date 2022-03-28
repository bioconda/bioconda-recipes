#!/bin/sh
set -x -e

RM_DIR=${PREFIX}/share/RepeatModeler
mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

# configure
cd ${RM_DIR}

# prompt 1: <PRESS ENTER TO CONTINUE>
# prompt 2: confirm path to running perl interpreter
# prompt 3: Configure for LTR structural search [y] or n? Answering y
printf "\n\ny\n" | perl ./configure \
    -cdhit_dir ${PREFIX}/bin \
    -genometools_dir ${PREFIX}/bin \
    -ltr_retriever_dir ${PREFIX}/bin \
    -mafft_dir ${PREFIX}/bin \
    -recon_dir ${PREFIX}/bin \
    -repeatmasker_dir ${PREFIX}/share/RepeatMasker \
    -rmblast_dir ${PREFIX}/bin \
    -rscout_dir ${PREFIX}/bin \
    -trf_dir ${PREFIX}/bin \
    -ucsctools_dir ${PREFIX}/bin \
    -ninja_dir ${PREFIX}/bin

# ----- add tools within the bin ------

# add RepeatModeler
ln -s ${RM_DIR}/RepeatModeler ${PREFIX}/bin/RepeatModeler

# add other tools
RM_OTHER_PROGRAMS="BuildDatabase LTRPipeline Refiner RepeatClassifier"
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${RM_DIR}/${name} ${PREFIX}/bin/${name}
done

# add utils
# note that not all utils are linked directly in bin/, but
# can still be accessed via ${PREFIX}/share/RepeatModeler/util/*.pl
RM_UTILS="alignAndCallConsensus.pl generateSeedAlignments.pl viewMSA.pl Linup"
for name in ${RM_UTILS} ; do
  ln -s ${RM_DIR}/util/${name} ${PREFIX}/bin/${name}
done
