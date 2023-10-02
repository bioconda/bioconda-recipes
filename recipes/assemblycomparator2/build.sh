#!/bin/bash


# First we put the necessary files in into the conda build directory:
cp snakefile config.yaml LICENSE $PREFIX
cp -r assets profiles report_subpipeline scripts tests $PREFIX

# And also check that apptainer is available on the system for later
#apptainer --version

# I'm not sure if I should pull the docker image so it is available in the cache?
#apptainer pull docker://cmkobel/assemblycomparator2:v2.5.5

# How do I save the necessary system variables?

# Added since last run:
# I hope these variables are accessible when the user activates the environment that runs ac2.
ASSCOM2_BASE=$PREFIX
ASSCOM2_PROFILE=${ASSCOM2_BASE}/profiles/apptainer/local
ASSCOM2_DATABASES=${ASSCOM2_BASE}/databases # The user should override this in their .bashrc if they want to use a different dir.

# I have to think about this one: the launcher is already activated right.
#echo "alias asscom2='conda run --live-stream --name asscom2_launcher snakemake --snakefile \${ASSCOM2_BASE}/snakefile --profile \${ASSCOM2_PROFILE} --configfile \${ASSCOM2_BASE}/config.yaml'" >> ~/.bashrc
# I think it is better to use backslash-sentinel, because then the user can change the variables after having activated the PREFIX environment, and the changes will have effect
alias asscom2='snakemake --snakefile \${ASSCOM2_BASE}/snakefile --profile \${ASSCOM2_PROFILE} --configfile \${ASSCOM2_BASE}/config.yaml'

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
