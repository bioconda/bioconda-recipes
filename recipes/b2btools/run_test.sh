#!/bin/bash

# Test locally? Read these articles:
# - https://bioconda.github.io/contributor/building-locally.html
# - https://docs.openfree.energy/en/stable/installation.html

echo "1) Testing b2bTools installation"

python -m b2bTools --help
status=$?

# Check if the status code is non-zero and exit with an error code
if [ $status -ne 0 ]; then
    echo "Error: b2bTools command failed with status code $status"
    exit $status
fi

python -m b2bTools --version
status=$?

# Check if the status code is non-zero and exit with an error code
if [ $status -ne 0 ]; then
    echo "Error: b2bTools command failed with status code $status"
    exit $status
fi

echo "2) Testing b2bTools for Single Seq mode"

cat <<EOT >> ./input_example.fasta
>SEQ_1
MEDLNVVDSINGAGSWLVANQALLLSYAVNIVAALAIIIVGLIIARMISNAVNRLMISRK

>SEQ_2
EPVRRNEFIIGVAYDSDIDQVKQILTNIIQSEDRILKDREMTVRLNELGASSINFVVRVW
EOT


python -m b2bTools --dynamine --disomine --efoldmine --agmata \
    --input_file ./input_example.fasta \
    --output_json_file ./input_example.fasta.json \
    --output_tabular_file ./input_example.fasta.csv \
    --metadata_file ./input_example.fasta.meta.csv
status=$?

# Check if the status code is non-zero and exit with an error code
if [ $status -ne 0 ]; then
    echo "Error: b2bTools command failed with status code $status"
    exit $status
fi

# Validate the presence and content of output files
files=("input_example.fasta.json" "input_example.fasta.csv" "input_example.fasta.meta.csv")
for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Output file $file not found"
        exit 1
    fi

    head "$file"

    # Check if the file is a CSV and has more than one row
    if [[ "$file" == *.csv ]]; then
        row_count=$(wc -l < "$file")
        if [ $row_count -le 1 ]; then
            echo "Error: Output file $file is a CSV with less than two rows"
            exit 1
        fi
    fi

    # Cleanup: remove input and output files
    if [ -f "$file" ]; then
        rm "$file"
    fi
done

rm ./input_example.fasta
echo "Testing b2bTools for Single Seq mode finished with success"

echo "3) Testing b2bTools for MSA mode"

cat <<EOT >> ./small_alignment.clustal
CLUSTAL O(1.2.4) multiple sequence alignment


SEQ_1      -VYVGNLGNNG	10
SEQ_2      RVRCGCLTRG-	10
            *  * * ..
EOT

python -m b2bTools \
  --mode msa \
  --dynamine --disomine --efoldmine --agmata \
  --input_file ./small_alignment.clustal \
  --output_json_file ./small_alignment.clustal.json \
  --output_tabular_file ./small_alignment.clustal.csv \
  --metadata_file ./small_alignment.clustal.meta.csv \
  --distribution_json_file ./small_alignment.clustal.distrib.json \
  --distribution_tabular_file ./small_alignment.clustal.distrib.csv

status=$?

# Check if the status code is non-zero and exit with an error code
if [ $status -ne 0 ]; then
    echo "Error: b2bTools command failed with status code $status"
    exit $status
fi

# Validate the presence and content of output files
files=("small_alignment.clustal.json" "small_alignment.clustal.csv" "small_alignment.clustal.meta.csv" "small_alignment.clustal.distrib.json" "small_alignment.clustal.distrib.csv")
for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Output file $file not found"
        exit 1
    fi

    head "$file"

    # Check if the file is a CSV and has more than one row
    if [[ "$file" == *.csv ]]; then
        row_count=$(wc -l < "$file")
        if [ $row_count -le 1 ]; then
            echo "Error: Output file $file is a CSV with less than two rows"
            exit 1
        fi
    fi

    # Cleanup: remove input and output files
    if [ -f "$file" ]; then
        rm "$file"
    fi
done

rm ./small_alignment.clustal
echo "Testing b2bTools for Single Seq mode finished with success"
