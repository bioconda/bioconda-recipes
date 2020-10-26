#!/bin/bash

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"  
cp olego $PREFIX/bin
cp olegoindex $PREFIX/bin
chmod +x $PREFIX/bin/olego
chmod +x $PREFIX/bin/olegoindex
