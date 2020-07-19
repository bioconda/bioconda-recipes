#!/bin/bash
./install.sh -d $PREFIX

BINARY_HOME=$PREFIX/bin
UTILITIES_HOME=$PREFIX/MGLToolsPckgs/AutoDockTools/Utilities24
ln -s $UTILITIES_HOME/prepare_ligand4.py $BINARY_HOME/prepare_ligand4.py
ln -s $UTILITIES_HOME/prepare_receptor4.py $BINARY_HOME/prepare_receptor4.py

if [ `uname` == Darwin ]; then
    # Malformed Mach-O files in package cause otool to error out
    rm ${PREFIX}/MGLToolsPckgs/binaries/{qconvex,qdelaunay,qhalf,qhull,qvoronoi,rbox,wget}
else
    # Stray OSX lib in linux tarball causes conda-build binary relocation to fail
    rm ${PREFIX}/MGLToolsPckgs/Pmv/hostappInterface/cinema4d/VertexColor.dylib
fi
