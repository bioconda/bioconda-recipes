#!/bin/bash

python2.7 -m pip install intervaltree
python2.7 -m pip install blosc
wget https://bootstrap.pypa.io/get-pip.py
pypy get-pip.py
pypy -m pip install intervaltree
pypy -m pip install blosc

mkdir -p $PREFIX/bin
cp -r clairvoyante dataPrepScripts $PREFIX/bin

cat > $PREFIX/bin/clairvoyante.py <<EOF
#!/usr/bin/env python

print ("Data preparation scripts:")
print ("$PREFIX/bin/dataPrepScripts")
print ("\n")
print ("Clairvoyante programs:")
print ("$PREFIX/bin/clairvoyante")
print ("\n")
EOF

chmod +x $PREFIX/bin/clairvoyante.py
