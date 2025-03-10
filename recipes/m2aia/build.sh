wget https://github.com/m2aia/m2aia/releases/download/v2024.01/M2aia-v2024.01.1285f33-Ubuntu20.04-linux-x86_64.tar.gz
tar xvfz M2aia-v2024.01.1285f33-Ubuntu20.04-linux-x86_64.tar.gz
#mv M2aia* M2aia
cp M2aia-v2024.01.1285f33-linux-x86_64/bin/lib* $PREFIX/lib/
PYM2AIA_VERSION_TAG=0.5.10 python3 -m pip install . -vv
