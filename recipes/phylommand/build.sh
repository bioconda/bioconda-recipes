cd src

# Link flags are on the wrong line, leads to problems with NLOPT enabled.
sed -i.bak 's/argv_parser.o \$(TREEATORLINKFLAGS)$/argv_parser.o/' Makefile 
sed -i.bak 's/\$(PP) -o treeator \$(OTREEATOR)/\$(PP) -o treeator \$(OTREEATOR) \$(TREEATORLINKFLAGS)/' Makefile

make

# Makefile has no install target 
mkdir -p $PREFIX/bin

mv pairalign $PREFIX/bin/
mv rudisvg $PREFIX/bin/
mv treeator $PREFIX/bin/
mv treebender $PREFIX/bin/
