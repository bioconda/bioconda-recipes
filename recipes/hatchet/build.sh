# Compile Gurobi

# Gurobi Makefile uses a variable called 'C++'
# Rename this inline to 'CPP' so we can override it with the correct compiler on 'make'
sed -i 's/C++/CPP/g' gurobi902/linux64/src/build/Makefile

(cd gurobi902/linux64/src/build && make CPP=${CXX})
(cd gurobi902/linux64/lib && ln -f -s ../src/build/libgurobi_c++.a libgurobi_c++.a)

mkdir -p $PREFIX/lib
cp gurobi902/linux64/lib/libgurobi90.so $PREFIX/lib

export CXXFLAGS=-pthread
export GUROBI_HOME=$(cd gurobi902 && pwd)
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
