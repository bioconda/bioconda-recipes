#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

#pushd ngs
#sed -i.bak "s#\$TOOLS = \"\"#\$TOOLS = \"gcc\"#" ngs-sdk/setup/konfigure.perl
#sed -i.bak "s#\$CPP  = 'g++' unless (\$CPP)#\$CPP  = \"${CXX}\"#" ngs-sdk/setup/konfigure.perl
#sed -i.bak "s#\$CC   = \"\$TOOLS -c\"#\$CC   = \"${CC}\"#" ngs-sdk/setup/konfigure.perl
#sed -i.bak "s#\$LD   = \$TOOLS#\$LD   = \"${LD}\"#" ngs-sdk/setup/konfigure.perl
#./configure \
#    --prefix=$PREFIX \
#    --build-prefix=$NCBI_OUTDIR
#make
#popd

pushd ncbi-vdb
sed -i.bak "s#\$TOOLS = \"\"#\$TOOLS = \"gcc\"#" setup/konfigure.perl
sed -i.bak "s#\$CPP  = 'g++' unless (\$CPP)#\$CPP  = \"${CXX}\"#" setup/konfigure.perl
sed -i.bak "s#\$CC   = \"\$TOOLS -c\"#\$CC   = \"${CC}\"#" setup/konfigure.perl
sed -i.bak "s#\$LD   = \$TOOLS#\$LD   = \"${LD}\"#" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
popd

pushd sra-tools
sed -i.bak "s#\$TOOLS = \"\"#\$TOOLS = \"gcc\"#" setup/konfigure.perl
sed -i.bak "s#\$CPP  = 'g++' unless (\$CPP)#\$CPP  = \"${CXX}\"#" setup/konfigure.perl
sed -i.bak "s#\$CC   = \"\$TOOLS -c\"#\$CC   = \"${CC}\"#" setup/konfigure.perl
sed -i.bak "s#\$LD   = \$TOOLS#\$LD   = \"${LD}\"#" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX \
    --debug
make
make install
popd
