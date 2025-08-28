#! /bin/bash
mkdir -p $PREFIX/bin

sed -i.bak 's/CC *=/CC ?=/; s/CCFLAGS *=/CCFLAGS +=/' Makefile

# Work around "unknown type name 'mach_port_t'" error
if [ x"$(uname)" == x"Darwin" ]; then
  CCFLAGS="$CCFLAGS -D_DARWIN_C_SOURCE"
  CPPFLAGS="$CPPFLAGS -D_DARWIN_C_SOURCE"
  export CCFLAGS CPPFLAGS
fi

export CFLAGS="$CFLAGS -I$PREFIX/include"
export CCFLAGS="$CCFLAGS -I$PREFIX/include"
export LDFLAGS="-I$PREFIX/include -L$PREFIX/lib"

make 
cp candidate_variants_finder $PREFIX/bin
cp -r dt_model $PREFIX/bin
cp emvc-2 $PREFIX/bin
