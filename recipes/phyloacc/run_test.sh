#!/bin/bash
set -e
set -o pipefail
set -x

# Runs test for PhyloAcc, including on a small simulated dataset that contains a fasta file, mod file,
# bed file, id subset file, and config file.

TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT
export TMPDIR=$TMP
cd $TMP

echo " ** DOWNLOADING TEST DATA."
files=(
  "bioconda-test-cfg.yaml"
  "id-subset.txt"
  "ratite.mod"
  "simu_500_200_diffr_2-1.bed"
  "simu_500_200_diffr_2-1.noanc.fa"
)

for file in "${files[@]}"; do
  if ! wget -q "https://github.com/phyloacc/PhyloAcc-test-data/raw/main/bioconda-test-data/$file"; then
    echo "Failed to download $file" >&2
    exit 1
  fi
done
echo " ** TEST DATA DOWNLOAD OK."

# echo " ** BEGIN BINARY TEST."
# if ! PhyloAcc-ST; then
#   echo " ** ERROR: Binary check failed for PhyloAcc-ST." >&2
#   exit 1
# fi

# if ! PhyloAcc-GT; then
#   echo " ** ERROR: Binary check failed for PhyloAcc-GT." >&2
#   exit 1
# fi
# echo " ** BINARY TEST OK."
# Can't do this because there are no options for the binaries that don't result in errors (e.g. --help or --version)

echo " ** BEGIN DEPCHECK TEST."
if ! phyloacc --depcheck; then
  echo " ** ERROR: Dependency check failed. Please ensure all dependencies are installed." >&2
  exit 1
fi
echo " ** DEPCHECK TEST OK."

echo " ** BEGIN PHYLOACC INTERFACE TEST."
if ! phyloacc --config bioconda-test-cfg.yaml --local; then
  echo " ** ERROR: PhyloAcc interface test failed. Please check the configuration and installation." >&2
  exit 1
fi
echo " ** INTERFACE TEST OK."

echo " ** BEGIN WORKFLOW TEST."
if ! snakemake -p --jobs 1 --cores 1 -s phyloacc-bioconda-test/phyloacc-job-files/snakemake/run_phyloacc.smk --configfile phyloacc-bioconda-test/phyloacc-job-files/snakemake/phyloacc-config.yaml; then
  echo " ** ERROR: PhyloAcc workflow test failed. Please check the Snakemake configuration and log files." >&2
  exit 1
fi
echo " ** WORKFLOW TEST OK."

echo " ** BEGIN POST-PROCESSING TEST."
if ! phyloacc_post.py -h; then
  echo " ** ERROR: Failed to display help message for phyloacc_post.py" >&2
  exit 1
fi
if ! phyloacc_post.py -i phyloacc-bioconda-test/; then
  echo " ** ERROR: Post-processing test failed. Please check the input directory and log files." >&2
  exit 1
fi
echo " ** POST-PROCESSING TEST OK."