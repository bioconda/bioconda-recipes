#!/bin/bash
mkdir -p $PREFIX/mgltools
./install.sh -d $PREFIX/mgltools
chmod 0755 ${PREFIX}/mgltools/bin/*
chmod 0755 ${PREFIX}/mgltools/MGLToolsPckgs/AutoDockTools/Utilities24/*.py
alias script_ligand4=$PREFIX/mgltools/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_ligand4.py
alias script_receptor4=$PREFIX/mgltools/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py