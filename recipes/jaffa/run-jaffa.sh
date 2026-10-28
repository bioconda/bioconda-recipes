#!/usr/bin/env bash
# Jaffa wrapper script for Bioconda
#
# This script creates a copy of the Jaffa package files into an automatically
# cleaned-up directory and generates a "tools.groovy" file.  This is necessary
# because of the somewhat non-general way of installing Jaffa.
#
# Author: Manuel Holtgrewe <manuel.holtgrewe@bihealth.de>
# Edit: Shiyi Yin <github.com/yinshiyi>
#
# Usage: jaffa-{runmode} <any argument to pass to Jaffa pipeline>

# Unofficial Bash Strict Mode (http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail

# Ensure the wrapper strictly uses the Conda environment binaries (e.g. OpenJDK 8)
# regardless of any system PATH or JAVA_HOME set in the user's shell profile.
if [ -n "${CONDA_PREFIX:-}" ]; then
    export JAVA_HOME="$CONDA_PREFIX"
    export PATH="$CONDA_PREFIX/bin:$PATH"
fi

# setup auto-cleaned temporary directory
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# copy over file
cp -a $PACKAGE_HOME/* $TMPDIR

# generate tools.groovy
COMMANDS="bpipe velveth velvetg oases trimmomatic samtools bowtie2 blat dedupe.sh reformat.sh blastn bedtools minimap2 gffread_bin gtfToGenePred process_transcriptome_align_table make_3_gene_fusion_table make_count_table make_final_table extract_seq_from_fasta make_simple_read_table make_simple_read_table_assembly compile_results split_fusion_reads"
for command in $COMMANDS; do
    echo "${command%.sh}=\"$(which $command)\"" >>$TMPDIR/tools.groovy
done

# actually launch Jaffa
set -x
if [ "$RUNMODE" != "jaffal" ]; then
    bpipe run $TMPDIR/JAFFA_$RUNMODE.groovy "$@"
else
    bpipe run $TMPDIR/JAFFAL.groovy "$@"
fi
