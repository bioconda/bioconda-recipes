cd ./src
#make \
#	GXX="${CXX}" \
#	AR="${AR}"

$CXX -DUSE_SHRT -std=c++11 -O3 -funroll-loops -fomit-frame-pointer -static -I \ 
	boost_1_80_0 -o dollo-cdp driver.cpp binary_character_matrix.cpp

mkdir -p $PREFIX/bin
cp dollo-cdp $PREFIX/bin/dollo-cdp
chmod +x $PREFIX/bin/dollo-cdp
