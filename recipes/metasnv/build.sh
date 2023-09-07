#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
tag=share/metasnv-${PKG_VERSION}/
odir=$PREFIX/$tag

make
mkdir -p $odir
cp -pr src $odir
cp -pr metaSNV.py $odir
cp -pr metaSNV_DistDiv.py $odir
cp -pr metaSNV_Filtering.py $odir
cp -pr metaSNV_subpopr.R $odir

# The scripts find their resources relative to themselves so they cannot be
# installed directly to bin/

cat >$PREFIX/bin/metaSNV.py <<EOF
#!/usr/bin/env bash

BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"

exec python \$BINDIR/../$tag/metaSNV.py "\$@"
EOF

cat >$PREFIX/bin/metaSNV_DistDiv.py <<EOF
#!/usr/bin/env bash

BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"

exec python \$BINDIR/../$tag/metaSNV_DistDiv.py "\$@"
EOF

cat >$PREFIX/bin/metaSNV_Filtering.py <<EOF
#!/usr/bin/env bash

BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"

exec python \$BINDIR/../$tag/metaSNV_Filtering.py "\$@"
EOF

cat >$PREFIX/bin/metaSNV_subpopr.R <<EOF
#!/usr/bin/env bash

BINDIR="\$(cd "\$(dirname "\${0}")" && pwd -P)"

exec Rscript \$BINDIR/../$tag/metaSNV_subpopr.R "\$@"
EOF

chmod +x $PREFIX/bin/metaSNV.py
chmod +x $PREFIX/bin/metaSNV_DistDiv.py
chmod +x $PREFIX/bin/metaSNV_Filtering.py
chmod +x $PREFIX/bin/metaSNV_subpopr.R
