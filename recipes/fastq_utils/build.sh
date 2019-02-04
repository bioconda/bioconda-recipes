mkdir -p $PREFIX/bin

export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

# Download the old Samtools fastq_utils needs for its bam.h

tar jxvf deps/samtools-0.1.19.tar.bz2 
pushd samtools-0.1.19
make
make razip
popd

# Run the main install

make
make install

# Copy executables into prefix

cp bin/* $PREFIX/bin
