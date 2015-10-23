#/bin/bash -eu

# resource: https://github.com/cyclus/ciclus/tree/master/java-jdk

# # this must exist because ln does not have the -r option in Mac. Apple, unix - but not!
relpath(){ python -c "import os.path; print(os.path.relpath('$1','${2:-$PWD}'))" ; }
LINKLOC="$PREFIX/lib/*/jli"

# clean up
rm -rf release README readme.txt Welcome.html *jli.* demo sample *.zip
mv * $PREFIX

# Install
JLI_REL=$(relpath $LINKLOC/*jli.* $PREFIX/lib)
ln -s $JLI_REL $PREFIX/lib
chmod +x $PREFIX/bin/* $PREFIX/jre/bin/*
chmod +x $PREFIX/lib/jexec $PREFIX/jre/lib/jexec
find $PREFIX -type f -name '*.so' -exec chmod +x {} \;

# Some clean up
rm -rf $PREFIX/release $PREFIX/README $PREFIX/Welcome.html
rm $PREFIX/DISCLAIMER
rm $PREFIX/LICENSE
rm $PREFIX/THIRD_PARTY_README
rm $PREFIX/ASSEMBLY_EXCEPTION
