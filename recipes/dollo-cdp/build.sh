cd ./src
make \
	GXX="${CXX}" \
	AR="${AR}"
mkdir -p $PREFIX/bin
cp dollo-cdp $PREFIX/bin/dollo-cdp
chmod +x $PREFIX/bin/dollo-cdp
