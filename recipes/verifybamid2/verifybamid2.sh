#!/bin/bash
# Wrapper for VerifyBAMID2
# Avoids name conflicts with standard VerifyBamID and
# provides each access to referencing resource files
# Usage:
# verifybamid2 <SVD_name> <density> <genome_build> <other> <args>
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

SVG="${1:-1000g}"
DENSITY="${2:-100k}"
GENOME="${3:-b38}"
if [[ $SVG == "-h" || $SVG == "--help" ]]; then
	echo "Usage: verifybamid2 <SVG_name> <density> <genome> <other> <VerifyBamID> <args>"
	echo "<SVG_name> can be 1000g 1000g.phase3 or hgdp"
	echo "<density> can be 100k or 10k"
	echo "<genome> can be b37 or b38"
	$DIR/VerifyBamID --help
else
	$DIR/VerifyBamID --SVDPrefix $DIR/resource/$SVG.$DENSITY.$GENOME.vcf.gz.dat "${@:4}"
fi
