#!/bin/sh

unset SPARK_HOME

# disable nbextension
jupyter=${CONDA_PREFIX}/bin/jupyter
$jupyter nbextension disable bdgenomics.mango.pileup
