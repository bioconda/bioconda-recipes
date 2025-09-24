#!/usr/bin/env bash

# default usage: ./download-mitosalt-db.sh
# custom usage:  ./download-mitosalt-db.sh -h (download DEFAULT_HG_URL)
# custom usage:  ./download-mitosalt-db.sh -m (download DEFAULT_MG_URL)
# custom usage:  ./download-mitosalt-db.sh -h <human_genome_url> -m (download DEFAULT_MG_URL)
# custom usage:  ./download-mitosalt-db.sh -m <mouse_genome_url>
# custom usage:  ./download-mitosalt-db.sh -h <human_genome_url> -m <mouse_genome_url>

# Default URLs
DEFAULT_HG_URL="https://www.dropbox.com/s/e1xwzye9hieewxz/human_g1k_v37.fasta.gz"
DEFAULT_MG_URL="ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.26_GRCm38.p6/GCF_000001635.26_GRCm38.p6_genomic.fna.gz"

# Flags to determine which genomes to process
download_human=false
download_mouse=false
human_url="$DEFAULT_HG_URL"
mouse_url="$DEFAULT_MG_URL"

# Function to display usage
usage() {
  echo "Usage: $0 [-h [human_genome_url]] [-m [mouse_genome_url]] [-b]"
  echo "  -h    Download and index human genome (optional custom URL)"
  echo "  -m    Download and index mouse genome (optional custom URL)"
  exit 1
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h)
      download_human=true
      if [[ -n $2 && $2 != -* ]]; then
        human_url="$2"
        shift
      fi
      ;;
    -m)
      download_mouse=true
      if [[ -n $2 && $2 != -* ]]; then
        mouse_url="$2"
        shift
      fi
      ;;
    *)
      usage
      exit 1
      ;;
  esac
  shift
done

# If no options were provided, prompt the user
if ! $download_human && ! $download_mouse; then
  printf "\nNo options provided. Please specify at least one genome to download."
  usage
fi

# MITOSALT_DATA is defined in build.sh, store the db there
if [[ ! -d "${MITOSALT_DATA}" ]]; then
  printf "\nDownloading MITOSALT database in the current directory\n\n"
else
  printf "\nDownloading MITOSALT database in ${MITOSALT_DATA}\n\n"
  mkdir -p "${MITOSALT_DATA}"
  cd "${MITOSALT_DATA}"
fi


# Function to download and process genome
download_and_process_human_genome() {
  HG_V=hg.fasta
  MTRCRS_V=human_mt_rCRS.fasta
  HGS_V=hg.size
  TMPFILE=tmp_file

  # Download human genome and extract mt genome
  printf "Downloading human genome from: $human_url \n"
  wget -O $TMPFILE $human_url
  gunzip -c $TMPFILE > genome/$HG_V
  faSize -detailed genome/$HG_V|egrep -v 'GL|MT' > genome/$HGS_V
  rm $TMPFILE
  echo 'MT' > tmp.txt
  faSomeRecords genome/$HG_V tmp.txt genome/$MTRCRS_V
  rm tmp.txt
  printf "\nMITOSALT database is downloaded.\n"
  
  # Build human index
  printf "\nBuild human index...\n"
  hisat2-build -p 4 genome/$HG_V genome/hg
  lastdb -uNEAR  genome/human_mt_rCRS genome/$MTRCRS_V
  samtools faidx genome/$HG_V
  samtools faidx genome/$MTRCRS_V
}

download_and_process_mouse_genome() {
  # Set variables
  MG_V=mm10.fasta
  MTM_V=mouse_mt.fasta
  MGS_V=mm10.size
  TMPFILE=tmp_file

  # Download mouse genome and extract mt genome 
  printf "Downloading mouse genome from: $mouse_url"
  wget -O $TMPFILE $mouse_url
  gunzip -c $TMPFILE > genome/$MG_V
  faSize -detailed genome/$MG_V|fgrep NC|fgrep -v 'NC_005089.1' > genome/$MGS_V
  rm $TMPFILE
  echo 'NC_005089.1' > tmp.txt
  faSomeRecords genome/$MG_V tmp.txt genome/$MTM_V
  rm tmp.txt
  printf "\nMITOSALT database is downloaded.\n"

  # Build mouse index 
  printf "\nBuild mouse index...\n"
  hisat2-build -p 4 genome/$MG_V genome/mm
  lastdb -uNEAR  genome/mouse_mt genome/$MTM_V
  samtools faidx genome/$MG_V
  samtools faidx genome/$MTM_V
}

# Execute functions based on user input
$download_human && download_and_process_human_genome
$download_mouse && download_and_process_mouse_genome

echo "Process completed."
exit 0
