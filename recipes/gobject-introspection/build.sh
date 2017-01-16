
#!/bin/bash

ln -s $PREFIX/lib $PREFIX/lib64

export XORG_PREFIX="/usr"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"

# Can only be built with python 2.7
export CFLAGS="-I$PREFIX/include -I$PREFIX/include/glib-2.0 -I$PREFIX/include/glib-2.0/gobject -I$PREFIX/include/glib-2.0/glib -I$PREFIX/include/glib-2.0/gio -I$PREFIX/include/gobject-introspection-1.0 -I$PREFIX/lib/glib-2.0/include -I$PREFIX/lib/libffi-3.2/include -I/usr/include -I/usr/include/X11 -I/usr/include/X11/extensions $CFLAGS"
export CXXFLAGS="$CFLAGS -std=c++0x"

export LDFLAGS="-L$PREFIX/lib64 -L$PREFIX/lib"

export LIBFFI_CFLAGS="-I$PREFIX/lib/libffi-3.2.1/include"
export LIBFFI_LIBS="-L$PREFIX/lib64 -lffi"

./configure \
    --prefix=$PREFIX \
    --with-python=$PYTHON \
    --disable-gtk-doc \
    --disable-doctool \
    --enable-introspection=yes
# WARNING: unrecognized options: --enable-introspection
make
# make check
make install

unlink $PREFIX/lib64
