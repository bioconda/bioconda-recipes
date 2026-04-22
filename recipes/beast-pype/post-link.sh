#!/usr/bin/env bash

echo "Running post-link (post build) script for beast-pype"
echo "Installing Jupyter kernels for Python and R"
python -m ipykernel install --user --name=beast_pype
python -m bash_kernel.install --user
Rscript -e 'IRkernel::installspec(name="beast_pype_R", displayname = "beast_pype_R")'
echo "Adding BDSKY and BEASTLabs to BEAST 2's package manager"
packagemanager -add BDSKY
packagemanager -add BEASTLabs
echo "Post-link script for beast-pype completed successfully"