#!/bin/bash

if [[ $(uname) == "Darwin" ]]; then
	echo "Configuring for OSX..."
	export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include -I$PREFIX/include/boost --stdlib=libstdc++"
	export CXXFLAGS="${CXXFLAGS} --stdlib=libstdc++"
else
	echo "Configuring for Linux..."
	export CPPFLAGS="-I$PREFIX/include"
fi

./configure --prefix=$PREFIX --with-boost=$PREFIX/include --with-mpi=$PREFIX/include --enable-maxk=128
make AM_CXXFLAGS=-Wall
make install 

WRAPPER_PATH="$PREFIX/bin/abyss-pe"
WRAPPED_PATH="$PREFIX/bin/abyss-pe.Makefile"
mv "$WRAPPER_PATH" "$WRAPPED_PATH"
chmod a-x "$WRAPPED_PATH"
cat >"${WRAPPER_PATH}" <<EOF
#!/bin/bash
$(sed 's|^#!/usr/bin/||;q' "$WRAPPED_PATH") '$WRAPPED_PATH' \$@
EOF
chmod u+x "$WRAPPER_PATH"
