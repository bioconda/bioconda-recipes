$PYTHON -m pip install . --ignore-installed --no-deps -vv
"${CC}" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -O3 -g -o ushuffle main.c ushuffle.c
install ushuffle $PREFIX/bin
