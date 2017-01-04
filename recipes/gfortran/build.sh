#!/bin/bash

# Install gcc to its very own prefix.
# GCC must not be installed to the same prefix as the environment,
# because $GCC_PREFIX/include is automatically considered to be a
# "system" header path.
# That could cause -I$PREFIX/include to be essentially ignored in users' recipes
# (It would still be on the search path, but it would be in the wrong position in the search order.)
GCC_PREFIX="$PREFIX/gcc"
mkdir "$GCC_PREFIX"
cd ..
mkdir build_gfortran
cd build_gfortran

ln -s "$PREFIX/lib" "$PREFIX/lib64"

if [ "$(uname)" == "Darwin" ]; then
    # On Mac, we expect that the user has installed the xcode command-line utilities (via the 'xcode-select' command).
    # The system's libstdc++.6.dylib will be located in /usr/lib, and we need to help the gcc build find it.
    export LDFLAGS="-Wl,-headerpad_max_install_names -Wl,-L${PREFIX}/lib -Wl,-L/usr/lib"
    export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib:/usr/lib"
    #export CFLAGS="-gdwarf-2"
    #export CXXFLAGS="-gdwarf-2"
    #export CPPFLAGS="-gdwarf-2"

    ../gcc-4.9.3/configure \
        --prefix="$GCC_PREFIX" \
        --with-gxx-include-dir="$GCC_PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX/lib" \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --with-boot-ldflags="$LDFLAGS" \
        --with-stage1-ldflags="$LDFLAGS" \
        --with-tune=generic \
        --disable-multilib \
        --enable-checking=release \
        --with-build-config=bootstrap-debug \
        --enable-languages=c,fortran
else
    # For reference during post-link.sh, record some
    # details about the OS this binary was produced with.
    mkdir -p "${PREFIX}/share"
    cat /etc/*-release > "${PREFIX}/share/conda-gcc-build-machine-os-details"
    export CFLAGS="-I${PREFIX}/include"
    export CXXFLAGS="-I${PREFIX}/include"
    export CPPFLAGS="-I${PREFIX}/include"
    export LDFLAGS="-L${PREFIX}/lib"
    ../gcc-5.2.0/configure \
        --prefix="$GCC_PREFIX" \
        --with-gxx-include-dir="$GCC_PREFIX/include/c++" \
        --bindir="$PREFIX/bin" \
        --datarootdir="$PREFIX/share" \
        --libdir="$PREFIX"/lib \
        --with-mpfr="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --enable-checking=release \
        --with-tune=generic \
        --disable-multilib \
        --enable-languages=c,fortran
fi
make -j"$CPU_COUNT"
make install-strip
#rm "$PREFIX/lib64"
mv "$PREFIX/bin/gcc" "$PREFIX/bin/gcc.mved"
mv "$PREFIX/bin/g++" "$PREFIX/bin/g++.mved"
mv "$PREFIX/bin/cpp" "$PREFIX/bin/cpp.mved"
mv "$PREFIX/bin/c++" "$PREFIX/bin/c++.mved"


