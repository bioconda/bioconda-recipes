cd src
ls *.cpp
make \
	GXX="${GXX}" \

mkdir -p $PREFIX/bin
cp dollo-cdp $PREFIX/bin/dollo-cdp
chmod +x $PREFIX/bin/dollo-cdp
