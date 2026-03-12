#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Compile Gurobi

if [[ "$OSTYPE" == "darwin"* ]]; then
	sudo installer -pkg gurobi12.0.3_macos_universal2.pkg -target /

	export GUROBI_HOME=/Library/gurobi1203
	# FindGUROBI.cmake searches linux64/, mac64/, and top-level lib/include
	# but the universal2 pkg installs to macos_universal2/; symlink so cmake finds them
	ln -sfn $GUROBI_HOME/macos_universal2/lib $GUROBI_HOME/lib
	ln -sfn $GUROBI_HOME/macos_universal2/include $GUROBI_HOME/include
	mkdir -p $PREFIX/lib
	cp -rf "$GUROBI_HOME/macos_universal2/lib/libgurobi120.dylib" "$PREFIX/lib"
else
	# Gurobi Makefile uses a variable called 'C++'
	# Rename this inline to 'CPP' so we can override it with the correct compiler on 'make'
	sed -i.bak 's/C++/CPP/g' gurobi1203/linux64/src/build/Makefile
	(cd gurobi1203/linux64/src/build && make CPP=${CXX})
	(cd gurobi1203/linux64/lib && ln -fs ../src/build/libgurobi_c++.a libgurobi_c++.a)

	export GUROBI_HOME="$(cd gurobi1203 && pwd)"
	mkdir -p $PREFIX/lib
	cp -rf "$GUROBI_HOME/linux64/lib/libgurobi120.so" "$PREFIX/lib"
fi

export CXXFLAGS="${CXXFLAGS} -O3 -pthread -I${PREFIX}/include ${LDFLAGS}"
${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
