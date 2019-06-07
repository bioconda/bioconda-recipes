#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

pushd ncbi-vdb
sed -i.bak "s#\$TOOLS = \"\"#\$TOOLS = '${GCC}'#" setup/konfigure.perl
sed -i.bak "s#\$CPP  = 'g++' unless (\$CPP)#\$CPP  = '${CXX}'#" setup/konfigure.perl
sed -i.bak "s#\$CC   = \"\$TOOLS -c\"#\$CC   = '${CC}'#" setup/konfigure.perl
sed -i.bak "s#\$LD   = \$TOOLS#\$LD   = '${LD}'#" setup/konfigure.perl
sed -i.bak "s#\$AR   = 'ar rc'#\$AR   = '${AR} rc'#" setup/konfigure.perl
sed -i.bak "s#\$ARX  = 'ar x'#\$ARX  = '${AR} x'#" setup/konfigure.perl
sed -i.bak "s#\$ARLS = 'ar t'#\$ARLS = '${AR} t'#" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
popd

pushd sra-tools
sed -i.bak "s#\$TOOLS = \"\"#\$TOOLS = '${GCC}'#" setup/konfigure.perl
sed -i.bak "s#\$CPP  = 'g++' unless (\$CPP)#\$CPP  = '${CXX}'#" setup/konfigure.perl
sed -i.bak "s#\$CC   = \"\$TOOLS -c\"#\$CC   = '${CC}'#" setup/konfigure.perl
sed -i.bak "s#\$LD   = \$TOOLS#\$LD   = '${LD}'#" setup/konfigure.perl
sed -i.bak "s#\$AR   = 'ar rc'#\$AR   = '${AR} rc'#" setup/konfigure.perl
sed -i.bak "s#\$ARX  = 'ar x'#\$ARX  = '${AR} x'#" setup/konfigure.perl
sed -i.bak "s#\$ARLS = 'ar t'#\$ARLS = '${AR} t'#" setup/konfigure.perl
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX \
    --debug
make
make install
popd
