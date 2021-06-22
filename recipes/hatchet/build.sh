# Compile Gurobi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo installer -pkg gurobi9.0.2_mac64.pkg -target /

    export GUROBI_HOME=/Library/gurobi902
    mkdir -p $PREFIX/lib
    cp $GUROBI_HOME/mac64/lib/libgurobi90.dylib $PREFIX/lib
else
    # Gurobi Makefile uses a variable called 'C++'
    # Rename this inline to 'CPP' so we can override it with the correct compiler on 'make'
    sed -i 's/C++/CPP/g' gurobi902/linux64/src/build/Makefile
    (cd gurobi902/linux64/src/build && make CPP=${CXX})
    (cd gurobi902/linux64/lib && ln -f -s ../src/build/libgurobi_c++.a libgurobi_c++.a)

    export GUROBI_HOME=$(cd gurobi902 && pwd)
    mkdir -p $PREFIX/lib
    cp $GUROBI_HOME/linux64/lib/libgurobi90.so $PREFIX/lib
fi

export CXXFLAGS=-pthread
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

