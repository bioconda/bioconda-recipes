#!/bin/bash
if [[  "$(uname -s )" == "Darwin" ]]; then
sed -i 's/strtok('\''\\0'\'',/strtok(NULL,/g' collect_mgf.c
sed -i '1i#include <unistd.h>' collect_mgf.c
else
sed -i '12c\#include <unistd.h>' collect_mgf.c
sed -i '58s/close/fclose/' collect_mgf.c
sed -i '85s/close/fclose/' collect_mgf.c
sed -i '89s/close/fclose/' collect_mgf.c
fi
"${CC}" ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o collect_mgf collect_mgf.c
install -d "${PREFIX}/bin"
install collect_mgf "${PREFIX}/bin/"
