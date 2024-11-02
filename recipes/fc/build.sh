
#!/bin/bash
set -xe
make CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="-g -Wall -O2 -L$PREFIX/lib"
chmod +x fc-virus
mkdir -p ${PREFIX}/bin
cp -f fc-virus ${PREFIX}/bin
