#!/bin/bash

# Note: This build script is not intended to be run directly. 
# It is used by the bioconda build system to create a conda package for the beast-pype software. 
# The script installs the necessary Python, Basha nd R kernels for Jupyter notebooks, as well as the required packages and extensions.

# Install the kernels for Jupyter notebooks
python -m ipykernel install --user --name=beast_pype
python -m bash_kernel.install --user
Rscript -e 'IRkernel::installspec(name="ir-beast_pype_R", displayname = "beast_pype_R")'

# Install the required packages for BEAST 2.
packagemanager -add BDSKY
packagemanager -add BEASTLabs

# Install the required Jupyter extensions for interactive widgets
jupyter nbextension enable --py --sys-prefix widgetsnbextension
jupyter labextension install @jupyter-widgets/jupyterlab-manager

# Install the beast-pype package itself
python -m pip install . -vv --no-deps --no-build-isolation --no-cache-dir