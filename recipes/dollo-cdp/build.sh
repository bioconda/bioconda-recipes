cd src
ls *.cpp
#make \
#	GXX="${GXX}" \
chmod +x ${CXX}
#${CXX} -DUSE_SHRT -std=c++11 -O3 -funroll-loops -fomit-frame-pointer -I ./boost_1_80_0 -o dollo-cdp ./driver.cpp ./binary_character_matrix.cpp
${CXX} -DUSE_SHRT -std=c++11 -I ./boost_1_80_0 -o dollo-cdp ./driver.cpp ./binary_character_matrix.cpp
#make GXX="${CXX}"
mkdir -p $PREFIX/bin
cp dollo-cdp $PREFIX/bin/dollo-cdp
chmod +x $PREFIX/bin/dollo-cdp
