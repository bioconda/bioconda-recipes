#!/bin/bash

python -m ipykernel install --user --name=beast_pype
python -m bash_kernel.install --user

packagemanager -add BDSKY
packagemanager -add BEASTLabs

jupyter nbextension enable --py --sys-prefix widgetsnbextension
jupyter labextension install @jupyter-widgets/jupyterlab-manager