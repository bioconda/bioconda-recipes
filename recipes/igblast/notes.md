# Notes on igblast packaging

Igblast is packaged somewhat strangely in that files required to run the program are not included with the binary distribution. Here, we download the optional_file and internal_data directories, which are required to run igblast. Since Igblast uses the environmental variable IGDATA to determine where these directories live, we also add `export IGDATA=$CONDA_ENV_DIR/include/igblast` to etc/activate.d and unset this variable in etc/deactivate.d so when the conda environment is activated this variable is available. We also include the useful edit_imgt_file.pl script, which we modify to remove a hardcoded perl shebang in favor of `#!/usr/bin/env perl`. 

See the [Igblast README](ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/README) for further information. 
