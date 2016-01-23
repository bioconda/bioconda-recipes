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
rm -rf release README readme.txt Welcome.html *jli.* demo sample *.zip DISCLAIMER LICENSE THIRD_PARTY_README ASSEMBLY_EXCEPTION

cp -r * $PREFIX
