mkdir -p $PREFIX/bin
./configure --disable-debugging 
make 

# cmfinder.pl requires env-var CMfinder be set to bin parent dir
mv bin/cmfinder.pl bin/_cmfinder.pl
echo 'export CMfinder='$PREFIX > bin/cmfinder.pl
echo '_cmfinder.pl "$@"' >> bin/cmfinder.pl
chmod +x bin/cmfinder.pl
cp bin/* $PREFIX/bin/ 
