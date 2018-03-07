export LD_LIBRARY_PATH=$PREFIX
cd src/

echo "> Compiling sources"
for F in $(find . -name "*.cpp") ; do
	FF=${F%.*}
	g++ -o $FF.o -fopenmp -c -Wall -Wextra -O3 -march=x86-64 -I./ -I${PREFIX}/include -L${PREFIX}/lib $FF.cpp
done;

echo "> Building target: cc.bin"
g++ -o cc.bin -fopenmp -I${PREFIX}/include -L${PREFIX}/lib -lboost_program_options $(find . -name "*.o")

cp cc.bin $PREFIX/bin
ln -s $PREFIX/bin/cc.bin $PREFIX/bin/canopy
