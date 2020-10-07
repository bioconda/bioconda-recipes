#!/bin/bash

# comment out random seed function srand() on line 454 for reproducibility
sed -i.bak '454 s|^| //|' genclustlb.c

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install genclust "${PREFIX}/bin/"
