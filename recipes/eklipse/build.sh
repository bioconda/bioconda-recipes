#!/bin/bash

curl -SL https://github.com/dooguypapua/eKLIPse/archive/refs/heads/master.zip -o eklipse.zip

unzip -d eklipse eklipse.zip
chmod a+x eklipse/*
mkdir -p "${PREFIX}/bin"
cp eklipse/eKLIPse_circos.py "${PREFIX}/bin/."
cp eklipse/eKLIPse_fct.py "${PREFIX}/bin/."
cp eklipse/eKLIPse_init.py "${PREFIX}/bin/."
cp eklipse/eKLIPse_sc.py "${PREFIX}/bin/."
cp eklipse/eKLIPse_threading.py "${PREFIX}/bin/."
cp eklipse/pybam.py "${PREFIX}/bin/."
cp eklipse/spinner.py "${PREFIX}/bin/."
cp eklipse/tabulate.py "${PREFIX}/bin/."