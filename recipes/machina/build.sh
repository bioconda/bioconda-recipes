# Compile Gurobi

# Gurobi Makefile uses a variable called 'C++'
# Rename this inline to 'CPP' so we can override it with the correct compiler on 'make'
sed -i 's/C++/CPP/g' gurobi902/linux64/src/build/Makefile

(cd gurobi902/linux64/src/build && make CPP=${CXX})
(cd gurobi902/linux64/lib && ln -f -s ../src/build/libgurobi_c++.a libgurobi_c++.a)

GUROBI_HOME=$(cd gurobi902 && pwd)

mkdir -p build && cd build
cmake .. \
  -DGUROBI_HOME=$GUROBI_HOME \
  -DLIBLEMON_ROOT=$PREFIX
make

mkdir -p $PREFIX/lib
cp $GUROBI_HOME/linux64/lib/libgurobi90.so $PREFIX/lib

mkdir -p $PREFIX/bin
cp cluster $PREFIX/bin
cp generatemigrationtrees $PREFIX/bin
cp generatemutationtrees $PREFIX/bin
cp pmh_sankoff $PREFIX/bin
cp pmh $PREFIX/bin
cp pmh_tr $PREFIX/bin
cp pmh_ti $PREFIX/bin
cp ms $PREFIX/bin
cp visualizeclonetree $PREFIX/bin
cp visualizemigrationgraph $PREFIX/bin
