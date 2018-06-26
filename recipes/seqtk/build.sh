 #!/bin/bash

export LDFLAGS="-L$PREFIX/lib"
  
sed -i.bak 's/\$(CFLAGS)/$(CPPFLAGS) $(CFLAGS) $(LDFLAGS)/' Makefile
sed -i.bak 's/^CC=gcc$//' Makefile
sed -i.bak 's/^CFLAGS=.*//' Makefile
sed -i.bak 's/^BIND.*//' Makefile

mkdir -p "${PREFIX}/bin"
make CC="${CC}" CPPFLAGS="${CPPFLAGS}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" BINDIR="${PREFIX}/bin" all

./seqtk seq

#cp -f seqtk "${PREFIX}/bin"
