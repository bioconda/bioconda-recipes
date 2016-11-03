sed -i.bak 's^TABIX_LIB_DIR)$^TABIX_LIB_DIR) -L$(PREFIX)/lib^' src/Makefile
sed -i.bak 's^TABIX_INCLUDE_DIR)$^TABIX_INCLUDE_DIR) -I$(PREFIX)/include^' src/Makefile
sed -i.bak "s^tabix: \(.*\)^tabix: \1\n\tsed -i.bak 's@CFLAGS =@CFLAGS = -I$\(PREFIX\)/include@' tabix*/Makefile^" redist/Makefile

make BIN_DIR=$PREFIX/bin
