#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
tag=share/metasnv-${PKG_VERSION}/
odir=$PREFIX/$tag

# Makefile hardcodes "CC=g++" so we need to comment that out
# And replace uses of $CC with $CXX
sed 's/^CC=g++/# CC=g++/' src/snpCaller/Makefile | sed 's/$(CC)/$(CXX)/' > src/snpCaller/Makefile.tmp
mv src/snpCaller/Makefile.tmp src/snpCaller/Makefile

make
mkdir -p $odir
cp -pr src $odir
cp -pr metaSNV.py $odir
cp -pr metaSNV_post.py $odir

# The scripts find their resources relative to themselves so they cannot be
# installed directly to bin/

cat >$PREFIX/bin/metaSNV_post.py <<EOF
#!/usr/bin/env bash

BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"

exec python \$BINDIR/../$tag/metaSNV_post.py "\$@"
EOF

cat >$PREFIX/bin/metaSNV.py <<EOF
#!/usr/bin/env bash

BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"

exec python \$BINDIR/../$tag/metaSNV.py "\$@"
EOF

chmod +x $PREFIX/bin/metaSNV.py
chmod +x $PREFIX/bin/metaSNV_post.py
