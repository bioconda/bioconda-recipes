#!/usr/bin/env bash

# default usage: download-mitosalt-db.sh
# custom usage:  download-mitosalt-db.sh -h (download DEFAULT_HG_URL)
# custom usage:  download-mitosalt-db.sh -m (download DEFAULT_MG_URL)
# custom usage:  download-mitosalt-db.sh -h <human_genome_url> -m (download DEFAULT_MG_URL)
# custom usage:  download-mitosalt-db.sh -m <mouse_genome_url>
# custom usage:  download-mitosalt-db.sh -h <human_genome_url> -m <mouse_genome_url>

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
if [[ -z "${MITOSALT_DATA:-}" ]]; then
  printf "\nDownloading MITOSALT database in the current directory\n\n"
else
  printf "\nDownloading MITOSALT database in %s\n\n" "$MITOSALT_DATA"
  mkdir -p "$MITOSALT_DATA"
  cd "$MITOSALT_DATA" || { echo "Failed to cd into $MITOSALT_DATA"; exit 1; }
fi

# Create genome directory if it doesn't exist
mkdir -p genome

# detect mitochondrial contig name in a fasta file
detect_mt_name() {
  local fasta="$1"
  [[ -f "${fasta}.fai" ]] || samtools faidx "$fasta"

  # Try common aliases first
  local id
  id=$(cut -f1 "${fasta}.fai" \
        | grep -E -m1 '^MT$|^chrM$|^chrMT$|^M$|NC_012920\.1|NC_005089\.1')

  # Fallback: pick a contig with mito-like length (15–20 kb)
  if [[ -z "$id" ]]; then
    id=$(awk '$2>=15000 && $2<=20000 {print $1; exit}' "${fasta}.fai")
  fi

  echo "$id"
}

# Functions to download and process genomes
download_and_process_human_genome() {
  HG_V=hg.fasta
  MTRCRS_V=human_mt_rCRS.fasta
  HGS_V=hg.size
  TMPFILE=tmp_file

  printf "Downloading human genome from: %s\n" "$human_url"
  wget -O "$TMPFILE" "$human_url"
  gunzip -c "$TMPFILE" > "genome/$HG_V"
  rm "$TMPFILE"

  # Index (needed for detection and downstream tools)
  samtools faidx "genome/$HG_V"

  # Exclude all common mito aliases from size list
  faSize -detailed "genome/$HG_V" \
    | egrep -v 'GL|MT|chrM|chrMT' > "genome/$HGS_V"

  # Detect mito contig
  MT_ID=$(detect_mt_name "genome/$HG_V")
  if [[ -z "$MT_ID" ]]; then
    echo "ERROR: could not detect mitochondrial contig in human FASTA."
    exit 1
  fi

  printf "%s\n" "$MT_ID" > tmp.txt
  faSomeRecords "genome/$HG_V" tmp.txt "genome/$MTRCRS_V"
  rm tmp.txt
  printf "\nMITOSALT database is downloaded.\n"

  printf "\nBuild human index...\n"
  hisat2-build -p 4 "genome/$HG_V" genome/hg
  lastdb -uNEAR genome/human_mt_rCRS "genome/$MTRCRS_V"
  # Fasta indexes already created for $HG_V; add for mt
  samtools faidx "genome/$MTRCRS_V"
}

download_and_process_mouse_genome() {
  MG_V=mm10.fasta
  MTM_V=mouse_mt.fasta
  MGS_V=mm10.size
  TMPFILE=tmp_file

  printf "Downloading mouse genome from: %s\n" "$mouse_url"
  wget -O "$TMPFILE" "$mouse_url"
  gunzip -c "$TMPFILE" > "genome/$MG_V"
  rm "$TMPFILE"

  # Index and detect mito contig
  samtools faidx "genome/$MG_V"
  MT_ID=$(detect_mt_name "genome/$MG_V")
  if [[ -z "$MT_ID" ]]; then
    echo "ERROR: could not detect mitochondrial contig in mouse FASTA."
    exit 1
  fi

  # Build size file excluding the mito contig (no hard-coded accession)
  faSize -detailed "genome/$MG_V" \
    | awk -v mt="$MT_ID" '$1!=mt' > "genome/$MGS_V"

  printf "%s\n" "$MT_ID" > tmp.txt
  faSomeRecords "genome/$MG_V" tmp.txt "genome/$MTM_V"
  rm tmp.txt
  printf "\nMITOSALT database is downloaded.\n"

  printf "\nBuild mouse index...\n"
  hisat2-build -p 4 "genome/$MG_V" genome/mm
  lastdb -uNEAR genome/mouse_mt "genome/$MTM_V"
  samtools faidx "genome/$MTM_V"
}

# Execute functions based on user input
$download_human && download_and_process_human_genome
$download_mouse && download_and_process_mouse_genome

echo "Process completed."
exit 0
