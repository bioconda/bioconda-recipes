mkdir -p "$PREFIX/share/man/man1"
pandoc --from markdown --to man ratt.1.md > "$PREFIX/share/man/man1/ratt.1"

mkdir -p "$PREFIX/lib/ratt"
cp RATT.* main.ratt.pl *.pm "$PREFIX/lib/ratt/"

cp ratt "$PREFIX/bin"
