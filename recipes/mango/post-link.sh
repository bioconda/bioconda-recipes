#!/bin/sh

# Set SPARK_HOME to conda installed pyspark package if not already set
if [ -z "${SPARK_HOME}" ]; then
    export SPARK_HOME=$( eval "echo ${PREFIX}/lib/python*/site-packages/pyspark" )
fi

# enable widget in environment
jupyter=${PREFIX}/bin/jupyter
$jupyter nbextension enable --py widgetsnbextension
$jupyter nbextension install --overwrite --py --symlink --user bdgenomics.mango.pileup
$jupyter nbextension enable bdgenomics.mango.pileup --user --py
