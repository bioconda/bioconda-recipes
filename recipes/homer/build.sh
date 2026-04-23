#!/bin/bash

outdir="$PREFIX/share/$PKG_NAME"
mkdir -p "$outdir"
mkdir -p "$outdir/bin"
mkdir -p "$PREFIX/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

sed -i.bak 's|-C "$homeDir/cpp/"|-C "$homeDir/cpp/" CXX=CXX DEBUG=CXXFLAGS|' configureHomer.pl
sed -i.bak "s|CXX=CXX DEBUG=CXXFLAGS|CXX=$CXX DEBUG=$CXXFLAGS|" configureHomer.pl
rm -f *.bak

chmod +rwx configureHomer.pl
cp -f configureHomer.pl $outdir/

( cd $outdir && perl configureHomer.pl -keepScript -install )

ls -1 $outdir/bin/ | grep -v old | sed -e "s/\*/ \\\/g" | while read id;
do
	chmod +x $outdir/bin/$id;
	ln -s $outdir/bin/$id $PREFIX/bin/$id;
done
