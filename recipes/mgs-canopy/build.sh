cd src/

echo "> Compiling sources"
for F in $(find . -name "*.cpp") ; do
    FF=${F%.*}
    "${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} \
        -o $FF.o -fopenmp -c -Wall -Wextra -O3 -march=x86-64 -I./ $FF.cpp
done

echo "> Building target: cc.bin"
"${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} \
    -o cc.bin -fopenmp $(find . -name "*.o") -lboost_program_options

install -d "${PREFIX}/bin"
install cc.bin "${PREFIX}/bin/"
ln -s "${PREFIX}/bin/cc.bin" "${PREFIX}/bin/canopy"
