#!/bin/bash

vcf=$1
outputs=$2
logs=$3
best_k_output=$4
best_k_logfile=$5
kmin=$6
kmax=$7
groups=$8
threshold_group=$9

directory=`dirname $0`
mkdir tmpdir$$

perl Snmf.pl -i $vcf -o $outputs -k $kmin -m $kmax -d ./tmpdir$$ -t $threshold_group

mv /tmpdir$$/output $best_k_output
mv /tmpdir$$/log $best_k_logfile
mv /tmpdir$$/outputs.Q $outputs
mv /tmpdir$$/logs $logs
mv /tmpdir$$/groups $groups
