#!/bin/bash
cp src/*.py $PREFIX/bin
cp src/stacking_only.par $PREFIX/bin

chmod +x $PREFIX/bin/BPs_to_CT.py
chmod +x $PREFIX/bin/cc06.py
chmod +x $PREFIX/bin/cc09.py
chmod +x $PREFIX/bin/dotknot.py
chmod +x $PREFIX/bin/functions.py
chmod +x $PREFIX/bin/kissing_hairpins.py
chmod +x $PREFIX/bin/longPK.py
chmod +x $PREFIX/bin/mwis_2d.py
chmod +x $PREFIX/bin/mwis.py
chmod +x $PREFIX/bin/pk_construction.py
chmod +x $PREFIX/bin/pk_energy.py
chmod +x $PREFIX/bin/pk_interrupted.py
chmod +x $PREFIX/bin/pk_recursive.py
chmod +x $PREFIX/bin/pk_tools.py
chmod +x $PREFIX/bin/secondary_elements.py
chmod +x $PREFIX/bin/stems.py
chmod +x $PREFIX/bin/user.py

ln -s $PREFIX/bin/dotknot.py $PREFIX/bin/dotknot
