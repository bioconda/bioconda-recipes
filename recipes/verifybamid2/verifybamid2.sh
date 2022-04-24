#!/bin/bash
# Wrapper for VerifyBAMID2
# Avoids name conflicts with standard VerifyBamID and
# provides each access to referencing resource files
# Usage:
# verifybamid2 <SVD_name> <marker_density> <genome_build> <other_vb2_args>
# or
# verifybamid2 <full_vb2_args>
set -eu -o pipefail

# Find original directory of bash script, resolving symlinks
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
SVD="${1:-1000g}"
DENSITY="${2:-100k}"
GENOME="${3:-b38}"

if [[ $SVD == "-h" || $SVD == "--help" ]]; then
	$DIR/VerifyBamID --help
elif [[ "$*" == *"--SVDPrefix"* ]]; then
	$DIR/VerifyBamID "$@"
elif [[ "$*" == *"--RefVCF"* ]]; then
	$DIR/VerifyBamID "$@"
else
#for backward compatibility
	$DIR/VerifyBamID --SVDPrefix $DIR/resource/$SVD.$DENSITY.$GENOME.vcf.gz.dat "${@:4}"
fi
