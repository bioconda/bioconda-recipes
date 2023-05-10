#!/bin/bash

curl -SL https://github.com/dooguypapua/eKLIPse/archive/refs/heads/master.zip -o eklipse.zip

unzip -d eklipse eklipse.zip
cd eklipse
chmod a+x *
mkdir -p "${PREFIX}/bin"
cp eKLIPse_circos.py eKLIPse_fct.py eKLIPse_init.py eKLIPse_sc.py eKLIPse_threading.py pybam.py spinner.py tabulate.py "${PREFIX}/bin/."