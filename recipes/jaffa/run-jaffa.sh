# Jaffa wrapper script for Bioconda
#
# This script creates a copy of the Jaffa package files into an automatically
# cleaned-up directory and generates a "tools.groovy" file.  This is necessary
# because of the somewhat non-general way of installing Jaffa.
#
# Author: Manuel Holtgrewe <manuel.holtgrewe@bihealth.de>
#
# Usage: jaffa-{runmode} <any argument to pass to Jaffa pipeline>

# Unofficial Bash Strict Mode (http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail

# setup auto-cleaned temporary directory
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# copy over file
cp -a $PACKAGE_HOME/* $TMPDIR

# generate tools.groovy
COMMANDS="bpipe velveth velvetg oases trimmomatic samtools bowtie2 blat dedupe.sh reformat.sh R"
for command in $COMMANDS; do
    echo "${command%.sh}=\"$(which $command)\"" >>$TMPDIR/tools.groovy
done

# actually launch Jaffa
set -x
bpipe run $TMPDIR/JAFFA_$RUNMODE.groovy $*
