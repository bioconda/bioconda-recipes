#!/bin/bash


cat <<EOF >> ${PREFIX}/.messages.txt


The config/ directory from AUGUSTUS can be accessed with the variable AUGUSTUS_CONFIG_PATH.
BRAKER2 requires this directory to be in a writable location, so if that is not the case, copy this directory to a writable location, e.g.:
cp -r $AUGUSTUS_CONFIG_PATH /absolute_path_to_user_writable_directory/
export AUGUSTUS_CONFIG_PATH=/absolute_path_to_user_writable_directory/config

Due to license and distribution restrictions, GeneMark, GenomeThreader and ProtHint should be additionally installed for BRAKER2 to fully work.
These packages can be either installed as part of the BRAKER2 environment, or the PATH variable should be configured to point to them.
The GeneMark key should be located in $HOME/.gm_key and GENEMARK_PATH should include the path to the GeneMark executables.


EOF
