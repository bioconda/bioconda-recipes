#!/bin/bash

echo Where is ncm.py located?
find /. -name ncm.py
echo

cd $BUILD_PREFIX
mv NGSCheckMate-1.0.0 $PREFIX/

cat << EOF > $PREFIX/ncm.py
#!/usr/bin/env bash

python /usr/local/NGSCheckMate-1.0.0/ncm.py "\$@"
EOF
