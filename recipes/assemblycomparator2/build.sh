#!/bin/bash


# First we put the necessary files in into the conda build directory:
cp snakefile config.yaml $PREFIX
cp -r assets profiles report_subpipeline scripts tests $PREFIX

# And also check that apptainer is available on the system for later
#apptainer --version

# I'm not sure if I should pull the docker image so it is available in the cache?
#apptainer pull docker://cmkobel/assemblycomparator2:v2.5.5


# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
