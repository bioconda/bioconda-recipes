#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/vcflatten

chmod +x bin/vcflatten
cp -r * $PREFIX/share/vcflatten

BIN=$PREFIX/bin/vcflatten

echo "#!/bin/bash" > $BIN
echo "$PREFIX/share/vcflatten/bin/vcflatten \$@" >> $BIN
chmod +x $BIN

