#!/bin/bash

cd $PREFIX
mv $SRC_DIR $PREFIX/NGSCheckMate-1.0.0

mkdir $PREFIX/bin
cat << EOF > $PREFIX/bin/ncm.py
#!/usr/bin/env bash

python /usr/local/NGSCheckMate-1.0.0/ncm.py "\$@"
EOF
