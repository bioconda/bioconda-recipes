#!/bin/bash
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o collect_mgf collect_mgf.c
install -d "${PREFIX}/bin"
install collect_mgf "${PREFIX}/bin/"
