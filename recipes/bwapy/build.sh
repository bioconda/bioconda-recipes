#!/bin/bash

make bwa/libbwa.a \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
"${PYTHON}" -m pip install . --no-deps -vv
