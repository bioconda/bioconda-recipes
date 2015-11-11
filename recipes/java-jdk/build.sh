#/bin/bash -eu

if [[ `uname` == "linux" ]]
then
    REFERER=http://www.azul.com/downloads/zulu/zulu-linux/
    URL=http://cdn.azulsystems.com/zulu/bin/zulu1.8.0_60-8.9.0.4-x86lx64.zip
    FILE=zulu1.8.0_60-8.9.0.4-x86lx64.zip
else
    REFERER=http://www.azul.com/downloads/zulu/zulu-mac/
    URL=http://cdn.azulsystems.com/zulu/bin/zulu1.8.0_60-8.9.0.4-macosx.zip
    FILE=zulu1.8.0_60-8.9.0.4-macosx.zip
fi

wget --referer=$REFERER $URL
unzip $FILE

# the rest is taken from https://github.com/cyclus/ciclus/tree/master/java-jdk

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
