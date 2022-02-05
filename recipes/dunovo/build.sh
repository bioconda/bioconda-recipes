
# Download submodules and move them to lib.

cat > submodules.txt <<EOF
kalign  0.3.0       makovalab-psu kalign-dunovo c0ef2de4a958aed47311ea86591debb3bada871143a6923bc6338ab2f99f2d5b
utillib 0.1.1-alpha NickSto       utillib       961f5a3481d1c0dbe00c258b9df2de541e5605f3de4ff25bcc3cec22922e7c06
ET      0.3         NickSto       ET            6b757b3ab3634b949f78692ac0db72e9264a1dceaf7449e921091d3ad0012eea
bfx     0.5.0       NickSto       bfx           f5cc5c9c8a627a082f8b505135aec10b47c09647269ad92abe3a1fa2f2059048
EOF

while read name version owner repo hash; do
  echo "Downloading $name v$version from $owner/$repo"
  wget --no-check-certificate "https://github.com/$owner/$repo/archive/v$version.tar.gz"
  downloaded_hash=`sha256sum "v$version.tar.gz" | tr -s ' ' | cut -d ' ' -f 1`
  if ! [ "$hash" == "$downloaded_hash" ]; then
    echo "Error: Hash does not match!" >&2
    return 1
  fi
  tar -zxvpf "v$version.tar.gz"
  rm -rf "$name"
  mv "$repo-$version" "$name"
  rm "v$version.tar.gz"
done < submodules.txt

# Compile binaries and move them to lib.
sed -i.bak "s#gcc#${CC}#g" Makefile
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
