make -C sumatra LDFLAGS="${LDFLAGS}" CC="${CC} ${CFLAGS} ${CPPFLAGS}"
make -C sumaclust LDFLAGS="${LDFLAGS}" CC="${CC} ${CFLAGS} ${CPPFLAGS}"
install -d "${PREFIX}/bin"
install sumatra/sumatra sumaclust/sumaclust "${PREFIX}/bin/"
