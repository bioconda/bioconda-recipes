cd src

# Link flags are on the wrong line, leads to problems with NLOPT enabled.
sed -i.bak 's/argv_parser.o \$(TREEATORLINKFLAGS)$/argv_parser.o/' Makefile 
sed -i.bak 's/\$(PP) -o treeator \$(OTREEATOR)/\$(PP) -o treeator \$(OTREEATOR) \$(TREEATORLINKFLAGS)/' Makefile

# CFLAGS, CPPFLAGS, and LDFLAGS are missing
sed -i.bak '/\$(PP).*-c/ s/-c/$(CFLAGS) -c/' Makefile
sed -i.bak '/\$(CC).*-c/ s/-c/$(CFLAGS) -c/' Makefile
sed -i.bak '/\$(PP).*-o/ s/-o/$(LDFLAGS) -o/' Makefile

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [[ "$(uname)" == "Linux" ]] ; then
    PP="$GXX -std=c++11"
    CC="$GCC"
elif [[ "$(uname)" == "Darwin" ]] ; then
    PP="$CXX -std=c++11"
    CC="$CC"
fi

make PP="$PP" CC="$CC" NLOPT=YES PTHREADS=YES

# Makefile has no install target 
mkdir -p $PREFIX/bin

mv pairalign $PREFIX/bin/
mv contree $PREFIX/bin/
mv treeator $PREFIX/bin/
mv treebender $PREFIX/bin/
