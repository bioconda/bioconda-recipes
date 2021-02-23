# Download and compile Gurobi 9.0.2
wget https://packages.gurobi.com/9.0/gurobi9.0.2_linux64.tar.gz -O gurobi9.0.2_linux64.tar.gz
tar xvzf gurobi9.0.2_linux64.tar.gz
sed -i 's/C++/CPP/g' gurobi902/linux64/src/build/Makefile
(cd gurobi902/linux64/src/build && make CPP=${CXX})
(cd gurobi902/linux64/lib && ln -f -s ../src/build/libgurobi_c++.a libgurobi_c++.a)

GUROBI_HOME=gurobi902

mkdir -p build && cd build
cmake .. \
  -DGUROBI_HOME=$GUROBI_HOME \
  -DLIBLEMON_ROOT=$CONDA_PREFIX/lib
make

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
