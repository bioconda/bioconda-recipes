#!/bin/bash
set -euo pipefail

PKGDIR="$SRC_DIR"
if [ ! -d "$PKGDIR/src" ]; then
  PKGDIR=$(find "$SRC_DIR" -maxdepth 2 -type d -name src | head -1 | xargs dirname)
fi

echo "SRC_DIR=$SRC_DIR"
echo "PKGDIR=$PKGDIR"

cat > "$PKGDIR/src/Makefile" <<'MAKE_EOF'
.PHONY: all tools-old clean distclean

all: tools-old

tools-old:
	rm -rf ./deps/libdeflate/build
	cmake -S ./deps/libdeflate -B ./deps/libdeflate/build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF
	cmake --build ./deps/libdeflate/build -j1
	cd ./deps/bzip2 && make clean || true && make CC="$(CC)" AR="$(AR)" RANLIB="$(RANLIB)"
	cd ./deps/xz && make clean || true && ./configure --prefix=$$(pwd)/install && make -j1 && make install
	cd ./deps/htslib && make clean || true && make \
		CC="$(CC)" AR="$(AR)" RANLIB="$(RANLIB)" \
		CPPFLAGS="-I$(PREFIX)/include" \
		CFLAGS="-I$(PREFIX)/include -O2 -fPIC" \
		LDFLAGS="-L$(PREFIX)/lib" \
		libhts.a
	$(MAKE) -C ./stringtie clean || true
	$(MAKE) -C ./stringtie \
		CC="$(CC)" CXX="$(CXX)" LINKER="$(CXX)" \
		LDFLAGS="-L$(PREFIX)/lib" \
		LIBS="../deps/htslib/libhts.a ../deps/libdeflate/build/libdeflate.a ../deps/xz/install/lib/liblzma.a ../deps/bzip2/libbz2.a -L$(PREFIX)/lib -lz -llzma -lbz2 -pthread" \
		CFLAGS="-I$(PREFIX)/include -I../deps/htslib -I../deps/libdeflate -I../deps/xz/install/include -I../deps/bzip2"

clean:
	$(MAKE) -C ./stringtie clean || true
	cd ./deps/htslib && make clean || true
	cd ./deps/bzip2 && make clean || true
	cd ./deps/xz && make clean || true
	rm -rf ./deps/xz/install
	rm -rf ./deps/libdeflate/build

distclean: clean
	find ./deps -name '*.o' -delete
	find ./deps -name '*.a' -delete
	find ./deps -name '*.so' -delete
	find ./deps -name '*.dylib' -delete
	find ./deps -name '*.la' -delete
	find ./deps -name '*.lo' -delete
	find ./deps -name '.DS_Store' -delete
	find ./deps -name '.libs' -type d -prune -exec rm -rf {} +
MAKE_EOF

sed -i '/^import(BSgenome\.Mmusculus\.UCSC\.mm10)$/d' "$PKGDIR/NAMESPACE"
sed -i '/BSgenome\.Mmusculus\.UCSC\.mm10/d' "$PKGDIR/DESCRIPTION" || true

cd "$PKGDIR/src"
make clean || true
make CC="$CC" CXX="$CXX" AR="$AR" RANLIB="$RANLIB" LINKER="$CXX" PREFIX="$PREFIX"
cd "$PKGDIR"

$R CMD INSTALL --build .
