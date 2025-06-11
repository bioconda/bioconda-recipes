#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Compile Gurobi

if [[ "$OSTYPE" == "darwin"* ]]; then
	sudo installer -pkg gurobi9.0.2_mac64.pkg -target /

	export GUROBI_HOME=/Library/gurobi902
	mkdir -p $PREFIX/lib
	cp -rf "$GUROBI_HOME/mac64/lib/libgurobi90.dylib" "$PREFIX/lib"
else
	# Gurobi Makefile uses a variable called 'C++'
	# Rename this inline to 'CPP' so we can override it with the correct compiler on 'make'
	sed -i.bak 's/C++/CPP/g' gurobi902/linux64/src/build/Makefile
	(cd gurobi902/linux64/src/build && make CPP=${CXX})
	(cd gurobi902/linux64/lib && ln -fs ../src/build/libgurobi_c++.a libgurobi_c++.a)

	export GUROBI_HOME="$(cd gurobi902 && pwd)"
	mkdir -p $PREFIX/lib
	cp -rf "$GUROBI_HOME/linux64/lib/libgurobi90.so" "$PREFIX/lib"
fi

export CXXFLAGS="${CXXFLAGS} -O3 -pthread -I${PREFIX}/include ${LDFLAGS}"
${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
