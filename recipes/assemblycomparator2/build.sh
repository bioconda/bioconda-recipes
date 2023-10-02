#!/bin/bash


# First we put the necessary files in into the conda build directory:
cp snakefile config.yaml LICENSE $PREFIX
cp -r assets profiles report_subpipeline scripts tests $PREFIX


# I hope these variables are accessible when the user activates the environment that runs ac2.
ASSCOM2_BASE=$PREFIX
ASSCOM2_PROFILE=${ASSCOM2_BASE}/profiles/apptainer/local
ASSCOM2_DATABASES=${ASSCOM2_BASE}/databases # The user should override this in their .bashrc if they want to use a different dir.

# I think it is better to use backslash-sentinel, because then the user can change the variables after having activated the PREFIX environment, and the changes will have effect
alias asscom2='snakemake --snakefile \${ASSCOM2_BASE}/snakefile --profile \${ASSCOM2_PROFILE} --configfile \${ASSCOM2_BASE}/config.yaml'
