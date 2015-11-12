#/bin/bash -eu

if [[ `uname` == "Linux" ]]
then
    REFERER=http://www.azul.com/downloads/zulu/zulu-linux/
    URL=http://cdn.azulsystems.com/zulu/bin/zulu1.8.0_60-8.9.0.4-x86lx64.zip
    NAME=zulu1.8.0_60-8.9.0.4-x86lx64
else
    REFERER=http://www.azul.com/downloads/zulu/zulu-mac/
    URL=http://cdn.azulsystems.com/zulu/bin/zulu1.8.0_60-8.9.0.4-macosx.zip
    NAME=zulu1.8.0_60-8.9.0.4-macosx
fi

wget --referer=$REFERER $URL
unzip $NAME.zip
mv $NAME/* .
rm -r $NAME

# the rest is taken from https://github.com/cyclus/ciclus/tree/master/java-jdk

# clean up
rm -rf release README readme.txt Welcome.html *jli.* demo sample *.zip
if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    mv lib/amd64/*.so lib
    rm -r lib/amd64
fi
mv * $PREFIX

# # this must exist because ln does not have the -r option in Mac. Apple, unix - but not!
#relpath(){ python -c "import os.path; print(os.path.relpath('$1','${2:-$PWD}'))" ; }
#LINKLOC="$PREFIX/lib/*/jli"

# Install
#JLI_REL=$(relpath $LINKLOC/*jli.* $PREFIX/lib)
#ln -s $JLI_REL $PREFIX/lib

#chmod +x $PREFIX/bin/* $PREFIX/jre/bin/*
#chmod +x $PREFIX/lib/jexec $PREFIX/jre/lib/jexec
#find $PREFIX -type f -name '*.so' -exec chmod +x {} \;

# Some clean up
rm -rf $PREFIX/release $PREFIX/README $PREFIX/Welcome.html
rm -f $PREFIX/DISCLAIMER
rm -f $PREFIX/LICENSE
rm -f $PREFIX/THIRD_PARTY_README
rm -f $PREFIX/ASSEMBLY_EXCEPTION
