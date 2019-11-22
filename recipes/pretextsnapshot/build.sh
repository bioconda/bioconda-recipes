#!/bin/bash

mkdir -p $PREFIX/bin

echo "#include<math.h>" >> test.c
echo "#include <stdlib.h>" >> test.c
echo "int main(int argc, char **argv){" >> test.c
echo "float x=sinf((float)atoi(argv[1]));" >> test.c
echo "return((int)x);}" >> test.c
clang -Ofast test.c -lm -o test
ldd test

chmod +x install
./install

shopt -s extglob
for file in $(compgen -G "Pretext!(*cpp)"); do
    chmod +x $file;
    mv $file $PREFIX/bin/
done
