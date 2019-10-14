#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Build boost
./build_boost.sh --toolset gcc
#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac
#sed -i.bak "13d" lib/Makefile.am
#sed -i.bak "13i\
#	-L${PREFIX}/lib \\" lib/Makefile.am
./autogen.sh
export PYTHON_NOVERSION_CHECK="3.7.0"
./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
#pushd lib/src
#$CXX $CXXFLAGS $LDFLAGS -lz -lpthread -static-libstdc++ -o $PREFIX/bin/kat_jellyfish sub_commands/jellyfish.o sub_commands/count_main.o sub_commands/info_main.o sub_commands/dump_main.o sub_commands/histo_main.o sub_commands/stats_main.o sub_commands/merge_main.o sub_commands/bc_main.o sub_commands/query_main.o sub_commands/cite_main.o sub_commands/mem_main.o jellyfish/merge_files.o libkat_jellyfish.la  -lz
#19:49:07 BIOCONDA INFO (OUT) libtool: link: $BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++ -g -O2 -std=c++0x -Wall -Wnon-virtual-dtor -Wno-deprecated-declarations -fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -I$PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/kat-2.4.2 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -static-libstdc++ -o bin/.libs/kat_jellyfish sub_commands/jellyfish.o sub_commands/count_main.o sub_commands/info_main.o sub_commands/dump_main.o sub_commands/histo_main.o sub_commands/stats_main.o sub_commands/merge_main.o sub_commands/bc_main.o sub_commands/query_main.o sub_commands/cite_main.o sub_commands/mem_main.o jellyfish/merge_files.o   -lpthread -L$PREFIX/lib ./.libs/libkat_jellyfish.so -lz -Wl,-rpath -Wl,$PREFIX/lib
make
make install
