#! /bin/bash

# seqtk is bundled with mapdamage. The path to seqtk is hardcoded in
# the mapdamage script so simply adding a dependency on seqtk won't
# work. Therefore we need to modify the makefile in order to tell
# mapdamage where zlib is located. We update CFLAGS and add LDFLAGS.
cat << EOF > $SRC_DIR/mapdamage/seqtk/Makefile
CC=gcc
CFLAGS=-g -Wall -O2 -Wno-unused-function -I${PREFIX}/include
LDFLAGS=-L${PREFIX}/lib

seqtk:seqtk.c khash.h kseq.h
		\$(CC) \$(CFLAGS) \$(LDFLAGS) seqtk.c -o \$@ -lz -lm

clean:
		rm -fr gmon.out *.o ext/*.o a.out seqtk *~ *.a *.dSYM session*
EOF

$PYTHON setup.py install
