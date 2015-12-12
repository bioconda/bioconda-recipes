#/bin/bash -eu

if [[ `uname` == "Linux" ]]
then
    REFERER=http://www.azul.com/downloads/zulu/zulu-linux/
    URL=http://cdn.azulsystems.com/zulu/bin/zulu1.7.0_91-7.12.0.3-x86lx64.zip
    NAME=zulu1.7.0_91-7.12.0.3-x86lx64
else
    REFERER=http://www.azul.com/downloads/zulu/zulu-mac/
    URL=http://cdn.azulsystems.com/zulu/bin/zulu1.7.0_91-7.12.0.3-macosx.zip
    NAME=zulu1.7.0_91-7.12.0.3-macosx
fi

wget --referer=$REFERER $URL
unzip $NAME.zip
mv $NAME/* .
rm -r $NAME

# clean up
rm -rf release README readme.txt Welcome.html *jli.* demo sample *.zip

if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    rm -r lib/amd64
fi
cp -r * $PREFIX

# more clean up
rm -rf $PREFIX/release $PREFIX/README $PREFIX/Welcome.html
rm -f $PREFIX/DISCLAIMER
rm -f $PREFIX/LICENSE
rm -f $PREFIX/THIRD_PARTY_README
rm -f $PREFIX/ASSEMBLY_EXCEPTION
