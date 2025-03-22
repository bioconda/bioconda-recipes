#!/bin/bash

# Test locally? Read these articles:
# - https://bioconda.github.io/contributor/building-locally.html
# - https://docs.openfree.energy/en/stable/installation.html

print_message() {
    current_time=$(date +"%Y-%m-%d %T")  # Include date and time
    yellow='\033[1;33m'
    no_color='\033[0m'
    echo -e "${yellow}[$current_time - b2bTools] run_test.sh: $1${no_color}"
}

preconditions() {
    print_message "0.1) Testing HMMER installation"

    print_message "0.1.a) Testing HMMER installation: hmmalign"
    hmmalign -h

    print_message "0.1.b) Testing HMMER installation: hmmsearch"
    hmmsearch -h

    print_message "0.2) Testing T-Coffee installation"
    t_coffee --help

    print_message "0.3) Testing b2bTools itself"
    b2bTools --help
}

postconditions() {
    print_message "Nothing to do actually."
}

scenario_single_seq_without_agmata_psper() {
    print_message "1.1) Testing b2bTools for Single Seq mode without AgMata nor PSPer"

    python -m b2bTools \
        --dynamine \
        --disomine \
        --efoldmine \
        --input_file ./test.singleseq.fasta \
        --output_json_file ./test.singleseq.fasta.json \
        --output_tabular_file ./test.singleseq.fasta.csv \
        --metadata_file ./test.singleseq.fasta.meta.csv
    b2bTools_command_status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ "$b2bTools_command_status" -ne 0 ]; then
        print_message "1.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("test.singleseq.fasta.json" "test.singleseq.fasta.csv" "test.singleseq.fasta.meta.csv")
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
        --input_file ./test.singleseq.fasta \
        --output_json_file ./test.singleseq.fasta.json \
        --output_tabular_file ./test.singleseq.fasta.csv \
        --metadata_file ./test.singleseq.fasta.meta.csv
    b2bTools_command_status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ "$b2bTools_command_status" -ne 0 ]; then
        print_message "1.2) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("test.singleseq.fasta.json" "test.singleseq.fasta.csv" "test.singleseq.fasta.meta.csv")
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
        --input_file ./test.singleseq.fasta \
        --output_json_file ./test.singleseq.fasta.json \
        --output_tabular_file ./test.singleseq.fasta.csv \
        --metadata_file ./test.singleseq.fasta.meta.csv
    b2bTools_command_status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ "$b2bTools_command_status" -ne 0 ]; then
        print_message "1.3) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("test.singleseq.fasta.json" "test.singleseq.fasta.csv" "test.singleseq.fasta.meta.csv")
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
    --input_file ./test.msa.fasta \
    --output_json_file ./test.msa.fasta.json \
    --output_tabular_file ./test.msa.fasta.csv \
    --metadata_file ./test.msa.fasta.meta.csv \
    --distribution_json_file ./test.msa.fasta.distrib.json \
    --distribution_tabular_file ./test.msa.fasta.distrib.csv

    b2bTools_command_status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ "$b2bTools_command_status" -ne 0 ]; then
        print_message "2.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("test.msa.fasta.json" "test.msa.fasta.csv" "test.msa.fasta.meta.csv" "test.msa.fasta.distrib.json" "test.msa.fasta.distrib.csv")
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
    --input_file ./test.msa.fasta \
    --output_json_file ./test.msa.fasta.json \
    --output_tabular_file ./test.msa.fasta.csv \
    --metadata_file ./test.msa.fasta.meta.csv \
    --distribution_json_file ./test.msa.fasta.distrib.json \
    --distribution_tabular_file ./test.msa.fasta.distrib.csv

    b2bTools_command_status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ "$b2bTools_command_status" -ne 0 ]; then
        print_message "2.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("test.msa.fasta.json" "test.msa.fasta.csv" "test.msa.fasta.meta.csv" "test.msa.fasta.distrib.json" "test.msa.fasta.distrib.csv")
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
        --input_file ./test.msa.fasta \
        --output_json_file ./test.msa.fasta.json \
        --output_tabular_file ./test.msa.fasta.csv \
        --metadata_file ./test.msa.fasta.meta.csv \
        --distribution_json_file ./test.msa.fasta.distrib.json \
        --distribution_tabular_file ./test.msa.fasta.distrib.csv

    b2bTools_command_status=$?

    # Check if the status code is non-zero and exit with an error code
    if [ "$b2bTools_command_status" -ne 0 ]; then
        print_message "2.1) Error: b2bTools command failed with status code $status"
        exit $status
    fi

    # Validate the presence and content of output files
    files=("test.msa.fasta.json" "test.msa.fasta.csv" "test.msa.fasta.meta.csv" "test.msa.fasta.distrib.json" "test.msa.fasta.distrib.csv")
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

print_message "Running test preconditions"
preconditions

# Scenarios for Single Sequence input
print_message "Running test scenarios for Single Sequence input"
scenario_single_seq_without_agmata_psper
scenario_single_seq_only_psper
scenario_single_seq_only_agmata

# Scenarios for Multiple Sequence Alignment input
print_message "Running test scenarios for Multiple Sequence Alignment input"
scenario_msa_without_agmata_psper
scenario_msa_only_psper
scenario_msa_only_agmata

print_message "Running test postconditions"
postconditions

print_message "All test scenarios have been executed with success"
exit 0
