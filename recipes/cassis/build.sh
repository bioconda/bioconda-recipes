mkdir -p "$PREFIX/lib/cassis"
mkdir -p "$PREFIX/bin"

cp -a * "$PREFIX/lib/cassis/"
rm "$PREFIX/lib/cassis/COPYING"

mv "$PREFIX/lib/cassis/cassis.pl" "$PREFIX/bin/cassis"
chmod +x "$PREFIX/bin/cassis"
