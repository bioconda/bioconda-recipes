#!/bin/bash
#set -euo pipefail

function is_file_emtpy()
{
    if ! [[ -s $1 ]] ; then
        exit 1
    fi
}

TESTDATA="https://github.com/bx3/shannon_cpp/releases/download/v0.4.0/sample.tar.gz"

wget -q $TESTDATA >/dev/null
tar -xvf sample.tar.gz >/dev/null

single_length=50
paired_1_length=100
paired_2_length=100

single_read_path="./sample/SE_read.fasta" 
paired_read_1_path="./sample/PE_read_1.fasta"
paired_read_2_path="./sample/PE_read_2.fasta"
output_dir="./sample_output"

num_threads=4
sampling=0
max_memory="4G"
sort_threads=1
random_seed=31
min_output_fasta_len=80

mkdir -p "./sample_output/single_output"
mkdir -p "./sample_output/paired_output"
single_output_dir='./sample_output/single_output'
paired_output_dir='./sample_output/paired_output'
single_reconstruct_fasta_path="${single_output_dir}/reconstructed_seq.fasta"
paired_reconstruct_fasta_path="${single_output_dir}/reconstructed_seq.fasta"

shannon_cpp shannon -l $single_length -s $single_read_path -o $single_output_dir -t $num_threads -g $sampling -m $max_memory -u $sort_threads -e $min_output_fasta_len --random_seed $random_seed >/dev/null

is_file_emtpy $single_reconstruct_fasta_path

shannon_cpp shannon -i $paired_1_length $paired_2_length -p $paired_read_1_path $paired_read_2_path -o $paired_output_dir -t $num_threads -g $sampling -m $max_memory -u $sort_threads -e $min_output_fasta_len --random_seed $random_seed >/dev/null

is_file_emtpy $paired_reconstruct_fasta_path

echo "Success"
