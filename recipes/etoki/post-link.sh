#!/bin/bash

set -euxo pipefail

# Update EToKi configuration
EToKi.py configure --usearch $(which blastp) \
  --path bbduk=$(which bbduk.sh) \
  --path bbmerge=$(which bbmerge.sh) \
  --path blastn=$(which blastn) \
  --path blastp=$(which blastp) \
  --path bowtie2=$(which bowtie2) \
  --path bowtie2build=$(which bowtie2-build) \
  --path bwa=$(which bwa) \
  --path diamond=$(which diamond) \
  --path fasttree=$(which FastTreeMP) \
  --path flye=$(which flye) \
  --path gatk=$(find $(which gatk3 | sed 's=bin/gatk3=opt=') -name "*GenomeAnalysisTK.jar" | head -n 1) \
  --path kraken2=$(which kraken2) \
  --path lastal=$(which lastal) \
  --path lastdb=$(which lastdb) \
  --path makeblastdb=$(which makeblastdb) \
  --path megahit=$(which megahit) \
  --path minimap2=$(which minimap2) \
  --path mmseqs=$(which mmseqs) \
  --path nextpolish=$(which nextPolish) \
  --path pilercr=$(which pilercr) \
  --path pilon=$(find $(which pilon | sed 's=bin/pilon=share=') -name "*pilon*jar" | head -n 1) \
  --path rapidnj=$(which rapidnj) \
  --path repair=$(which repair.sh) \
  --path raxml=$(which raxmlHPC) \
  --path raxml_ng=$(which raxml-ng) \
  --path samtools=$(which samtools) \
  --path spades=$(which spades.py) \
  --path trf=$(which trf)



# Write a message for the user
cat <<EOF >> ${PREFIX}/.messages.txt
Default paths have been set up for Etoki, to manually change them use "Etoki.py configure"
EOF
