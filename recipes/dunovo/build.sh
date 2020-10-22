#!/bin/bash

# Download submodules and move them to lib.
get_submodule () {
  read name version owner repo hash <<< "$@"
  wget --no-check-certificate "https://github.com/$owner/$repo/archive/v$version.tar.gz"
  downloaded_hash=`sha256sum "v$version.tar.gz" | tr -s ' ' | cut -d ' ' -f 1`
  if ! [ "$hash" == "$downloaded_hash" ]; then
    echo "Error: Hash does not match!" >&2
    return 1
  fi
  tar -zxvpf "v$version.tar.gz"
  rm -rf "$name"
  if [ "$name" == kalign ]; then
    mv "$repo-$version" "$name"
  else
    mv "$repo-$version" "$PREFIX/lib/$name"
  fi
  rm "v$version.tar.gz"
}
get_submodule kalign  0.2.0 makovalab-psu kalign-dunovo 473dd562f520a218df2dd147c89940422344adad6d8824141bffe6466c6d40e7
get_submodule utillib 0.1.0 NickSto       utillib       bffe515f7bd98661657c26003c41c1224f405c3a36ddabf5bf961fab86f9651a
get_submodule ET      0.2.2 NickSto       ET            11dc5cb02521a2260e6c88a83d489c72f819bd759aeff31d66aa40ca2f1358a6
get_submodule bfx     0.2.0 NickSto       bfx           252d31dc260882f203d04624945c8abb4940f3ae4b03a5050182d23854488ef8

# Inject compilers
sed -i.bak 's#gcc#${CC}#g' Makefile

# Compile binaries and move them to lib.
make CC=$CC
mv *.so "$PREFIX/lib"
mv kalign "$PREFIX/lib"

# Move scripts to lib and link to them from bin.
for script in *.awk *.sh *.py; do
  mv "$script" "$PREFIX/lib"
  ln -s "../lib/$script" "$PREFIX/bin"
done

# Handle special cases.
mv utils/precheck.py "$PREFIX/lib"
ln -s ../lib/precheck.py "$PREFIX/bin"
ln -s ../lib/bfx/trimmer.py "$PREFIX/bin"
mv VERSION "$PREFIX/lib"
