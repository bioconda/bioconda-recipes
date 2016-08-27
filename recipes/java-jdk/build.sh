#/bin/bash -eu

if [[ `uname` == "Linux" ]]
then
    REFERER=http://www.azul.com/downloads/zulu/zulu-linux/
    URL=http://cdn.azul.com/zulu/bin/zulu8.15.0.1-jdk8.0.92-linux_x64.tar.gz
    NAME=zulu8.15.0.1-jdk8.0.92-linux_x64
else
    REFERER=http://www.azul.com/downloads/zulu/zulu-mac/
    URL=http://cdn.azul.com/zulu/bin/zulu8.15.0.1-jdk8.0.92-macosx_x64.zip
    NAME=zulu8.15.0.1-jdk8.0.92-macosx_x64
fi

wget --referer=$REFERER $URL
if [[ `uname` == "Linux" ]]
then
    tar -xpf $NAME.tar.gz
else
    unzip $NAME.zip
fi
mv $NAME/* .
rm -r $NAME

# clean up
rm -rf release README readme.txt Welcome.html *jli.* demo sample *.zip

if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    mv lib/amd64/*.so lib
    rm -r lib/amd64
    # libnio.so does not find this within jre/lib/amd64 subdirectory
    cp jre/lib/amd64/libnet.so lib

    # fonts
    mkdir -p jre/lib/fonts
    cd jre/lib/fonts
    wget --no-check-certificate http://sourceforge.net/projects/dejavu/files/dejavu/2.36/dejavu-fonts-ttf-2.36.tar.bz2
    tar -xjvpf dejavu-fonts-ttf-2.36.tar.bz2
    mv dejavu-fonts-ttf-*/ttf/* .
    rm -rf dejavu-fonts-ttf-*
    cd ../../..
fi

mv * $PREFIX

# more clean up
rm -rf $PREFIX/release $PREFIX/README $PREFIX/Welcome.html
rm -f $PREFIX/DISCLAIMER
rm -f $PREFIX/LICENSE
rm -f $PREFIX/THIRD_PARTY_README
rm -f $PREFIX/ASSEMBLY_EXCEPTION
