#!/usr/bin/env bash

set -x
set -e

rebar --version

# Dataset: Toy1
rebar dataset download --name toy1 --tag custom --output-dir dataset/toy1
rebar run --dataset-dir dataset/toy1 --populations "*" --mask 0,0 --min-length 3 --output-dir output/toy1
rebar plot  --run-dir output/toy1 --annotations dataset/toy1/annotations.tsv

# Dataset: SARS-CoV-2
rebar dataset download --name sars-cov-2 --tag 2023-11-30 --output-dir dataset/sars-cov-2/2023-11-30
rebar run --dataset-dir dataset/sars-cov-2/2023-11-30  --populations "AY.4.2*,BA.5.2,XBC.1.6*,XBB.1.5.1,XBL" --output-dir output/sars-cov-2
rebar plot --run-dir output/sars-cov-2 --annotations dataset/sars-cov-2/2023-11-30/annotations.tsv
