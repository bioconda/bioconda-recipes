#!/bin/bash

# Test locally? Read these articles:
# - https://bioconda.github.io/contributor/building-locally.html
# - https://docs.openfree.energy/en/stable/installation.html

cat <<EOT >> ./input_example.fasta
>SEQ_1
MEDLNVVDSINGAGSWLVANQALLLSYAVNIVAALAIIIVGLIIARMISNAVNRLMISRK

>SEQ_2
EPVRRNEFIIGVAYDSDIDQVKQILTNIIQSEDRILKDREMTVRLNELGASSINFVVRVW
EOT

cat <<EOT >> ./small_alignment.clustal
CLUSTAL O(1.2.4) multiple sequence alignment


SEQ_1      -VYVGNLGNNG	10
SEQ_2      RVRCGCLTRG-	10
            *  * * ..
EOT

print_message() {
    current_time=$(date +"%T")
    echo "[$current_time - b2bTools] run_test.sh: $1"
}

preconditions() {
    print_message "Testing HMMER dependencies"

    hmmalign -h
    hmmsearch -h

    print_message "Testing T-Coffee dependencies"
    t_coffee --help

    print_message "Testing b2bTools itself"
    b2bTools -h
}

postconditions() {
    print_message "Removing testing files"

    rm ./input_example.fasta ./small_alignment.clustal
}

scenario_single_seq_without_agmata_psper() {
    print_message "1.1) Testing b2bTools for Single Seq mode without AgMata nor PSPer"

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        echo "Error: b2bTools command failed with status code $status"
        exit $status
    fi

    python -m b2bTools \
        --dynamine \
        --disomine \
        --efoldmine \
        --input_file ./input_example.fasta \
        --output_json_file ./input_example.fasta.json \
        --output_tabular_file ./input_example.fasta.csv \
        --metadata_file ./input_example.fasta.meta.csv
    status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        print_message "1.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("input_example.fasta.json" "input_example.fasta.csv" "input_example.fasta.meta.csv")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_message "1.1) Error: Output file $file not found"
            exit 1
        fi

        # Check if the file is a CSV and has more than one row
        if [[ "$file" == *.csv ]]; then
            row_count=$(wc -l < "$file")
            if [ $row_count -le 1 ]; then
                print_message "1.1) Error: Output file $file is a CSV with less than two rows"
                exit 1
            fi
        fi

        # Cleanup: remove input and output files
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done

    print_message "1.1) Testing b2bTools for Single Seq mode finished with success"
}

scenario_single_seq_only_psper() {
    print_message "1.2) Testing b2bTools for Single Seq mode using PSPer"

    python -m b2bTools \
        --psper \
        --input_file ./input_example.fasta \
        --output_json_file ./input_example.fasta.json \
        --output_tabular_file ./input_example.fasta.csv \
        --metadata_file ./input_example.fasta.meta.csv
    status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        print_message "1.2) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("input_example.fasta.json" "input_example.fasta.csv" "input_example.fasta.meta.csv")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_message "1.2)Error: Output file $file not found"
            exit 1
        fi

        # Check if the file is a CSV and has more than one row
        if [[ "$file" == *.csv ]]; then
            row_count=$(wc -l < "$file")
            if [ $row_count -le 1 ]; then
                print_message "1.2) Error: Output file $file is a CSV with less than two rows"
                exit 1
            fi
        fi

        # Cleanup: remove input and output files
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done

    print_message "1.2) Testing b2bTools for Single Seq mode finished with success"
}

scenario_single_seq_only_agmata() {
    print_message "1.3) Testing b2bTools for Single Seq mode using Agmata"

    python -m b2bTools \
        --agmata \
        --input_file ./input_example.fasta \
        --output_json_file ./input_example.fasta.json \
        --output_tabular_file ./input_example.fasta.csv \
        --metadata_file ./input_example.fasta.meta.csv
    status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        print_message "1.3) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("input_example.fasta.json" "input_example.fasta.csv" "input_example.fasta.meta.csv")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_message "1.3)Error: Output file $file not found"
            exit 1
        fi

        # Check if the file is a CSV and has more than one row
        if [[ "$file" == *.csv ]]; then
            row_count=$(wc -l < "$file")
            if [ $row_count -le 1 ]; then
                print_message "1.3) Error: Output file $file is a CSV with less than two rows"
                exit 1
            fi
        fi

        # Cleanup: remove input and output files
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done

    print_message "1.3) Testing b2bTools for Single Seq mode finished with success"
}

scenario_msa_without_agmata_psper() {
    print_message "2.1) Testing b2bTools for MSA mode without AgMata nor PSPer"

    python -m b2bTools \
    --mode msa \
    --dynamine \
    --disomine \
    --efoldmine \
    --input_file ./small_alignment.clustal \
    --output_json_file ./small_alignment.clustal.json \
    --output_tabular_file ./small_alignment.clustal.csv \
    --metadata_file ./small_alignment.clustal.meta.csv \
    --distribution_json_file ./small_alignment.clustal.distrib.json \
    --distribution_tabular_file ./small_alignment.clustal.distrib.csv

    status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        print_message "2.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("small_alignment.clustal.json" "small_alignment.clustal.csv" "small_alignment.clustal.meta.csv" "small_alignment.clustal.distrib.json" "small_alignment.clustal.distrib.csv")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_message "2.1) Error: Output file $file not found"
            exit 1
        fi

        # Check if the file is a CSV and has more than one row
        if [[ "$file" == *.csv ]]; then
            row_count=$(wc -l < "$file")
            if [ $row_count -le 1 ]; then
                print_message "2.1) Error: Output file $file is a CSV with less than two rows"
                exit 1
            fi
        fi

        # Cleanup: remove input and output files
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done

    print_message "2.1) Testing b2bTools for MSA mode finished with success"
}

scenario_msa_only_psper() {
    print_message "2.2) Testing b2bTools for MSA mode with PSPer"

    python -m b2bTools \
    --mode msa \
    --psper \
    --input_file ./small_alignment.clustal \
    --output_json_file ./small_alignment.clustal.json \
    --output_tabular_file ./small_alignment.clustal.csv \
    --metadata_file ./small_alignment.clustal.meta.csv \
    --distribution_json_file ./small_alignment.clustal.distrib.json \
    --distribution_tabular_file ./small_alignment.clustal.distrib.csv

    status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        print_message "2.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("small_alignment.clustal.json" "small_alignment.clustal.csv" "small_alignment.clustal.meta.csv" "small_alignment.clustal.distrib.json" "small_alignment.clustal.distrib.csv")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_message "2.1) Error: Output file $file not found"
            exit 1
        fi

        # Check if the file is a CSV and has more than one row
        if [[ "$file" == *.csv ]]; then
            row_count=$(wc -l < "$file")
            if [ $row_count -le 1 ]; then
                print_message "2.1) Error: Output file $file is a CSV with less than two rows"
                exit 1
            fi
        fi

        # Cleanup: remove input and output files
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done
}

scenario_msa_only_agmata() {
    print_message "2.2) Testing b2bTools for MSA mode with PSPer"

    python -m b2bTools \
    --mode msa \
    --agmata \
    --input_file ./small_alignment.clustal \
    --output_json_file ./small_alignment.clustal.json \
    --output_tabular_file ./small_alignment.clustal.csv \
    --metadata_file ./small_alignment.clustal.meta.csv \
    --distribution_json_file ./small_alignment.clustal.distrib.json \
    --distribution_tabular_file ./small_alignment.clustal.distrib.csv

    status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ $status -ne 0 ]; then
        print_message "2.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("small_alignment.clustal.json" "small_alignment.clustal.csv" "small_alignment.clustal.meta.csv" "small_alignment.clustal.distrib.json" "small_alignment.clustal.distrib.csv")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_message "2.1) Error: Output file $file not found"
            exit 1
        fi

        # Check if the file is a CSV and has more than one row
        if [[ "$file" == *.csv ]]; then
            row_count=$(wc -l < "$file")
            if [ $row_count -le 1 ]; then
                print_message "2.1) Error: Output file $file is a CSV with less than two rows"
                exit 1
            fi
        fi

        # Cleanup: remove input and output files
        if [ -f "$file" ]; then
            rm "$file"
        fi
    done
}

print_message "Running test scenarios"

preconditions

# Scenarios for Single Sequence input
scenario_single_seq_without_agmata_psper
scenario_single_seq_only_psper
scenario_single_seq_only_agmata

# Scenarios for Multiple Sequence Alignment input
scenario_msa_without_agmata_psper
scenario_msa_only_psper
scenario_msa_only_agmata

postconditions

print_message "All test scenarios have been executed with success"
