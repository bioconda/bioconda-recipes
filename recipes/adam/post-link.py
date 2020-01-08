#!/bin/sh

# Set SPARK_HOME to conda installed pyspark package if not already set
if [ -z "${SPARK_HOME}" ]; then
    export SPARK_HOME=$( eval "echo ${PREFIX}/lib/python*/site-packages/pyspark" )
fi
