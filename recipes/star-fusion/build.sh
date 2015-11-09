#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib/STAR-Fusion

cp -r * $PREFIX/lib/STAR-Fusion

echo "#!/bin/bash" > $PREFIX/bin/STAR-Fusion
echo "$PREFIX/lib/STAR-Fusion/STAR-Fusion \$@" >> $PREFIX/bin/STAR-Fusion
chmod +x $PREFIX/bin/STAR-Fusion
