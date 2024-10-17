#!/bin/bash
mkdir -p ${PREFIX}/bin
for f in *.py;
do
sed -i "1i #!/usr/bin/env python3" "$f"
done
chmod +x *.py
mv *.py $PREFIX/bin
