#!/bin/bash
set -euo pipefail

# Build ssu-align
./configure --prefix=$PREFIX


make
make install

# create wrapper scripts that set the SSUALIGNDIR env variable then runs the program
SSUDIR=$PREFIX/share/ssu-align-$PKG_VERSION

cd $PREFIX/bin
for f in ssu-align ssu-build ssu-draw ssu-mask ssu-merge ssu-prep
do
    mv $f _$f
    cat > ./$f << EOF
#!/bin/bash
set -e

export SSUALIGNDIR=$SSUDIR
_$f \$*
EOF
chmod 755 $f
done

