# Download and compile Gurobi 9.0.2
wget https://packages.gurobi.com/9.0/gurobi9.0.2_linux64.tar.gz -O gurobi9.0.2_linux64.tar.gz
tar xvzf gurobi9.0.2_linux64.tar.gz
(cd gurobi902/linux64/src/build && make)
(cd gurobi902/linux64/lib && ln -f -s ../src/build/libgurobi_c++.a libgurobi_c++.a)

# Set envvar so our cmake script can find it
export GUROBI_HOME=$(realpath gurobi902)

mkdir -p $PREFIX/lib
cp gurobi902/linux64/lib/libgurobi90.so $PREFIX/lib

export CXXFLAGS=-pthread
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
