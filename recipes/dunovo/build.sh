
# Compile binaries and move them to lib.
make
mkdir -p "$PREFIX/lib"
mv *.so "$PREFIX/lib"
while read name rest; do
  mv "$name" "$PREFIX/lib/$name"
done < submodules.txt

# Move scripts to lib and link to them from bin.
mkdir -p "$PREFIX/bin"
for script in *.awk *.sh *.py; do
  mv "$script" "$PREFIX/lib"
  ln -s "../lib/$script" "$PREFIX/bin/$script"
done
# Handle special cases.
mv utils/precheck.py "$PREFIX/lib"
ln -s ../lib/precheck.py "$PREFIX/bin"
ln -s ../lib/bfx/trimmer.py "$PREFIX/bin"
mv VERSION "$PREFIX/lib"
