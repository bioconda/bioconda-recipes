# all scripts, including the main one, are in the scripts/ directory
mkdir -p "$PREFIX/libexec/assemblytics"
cp scripts/* "$PREFIX/libexec/assemblytics/"

# move the main script out of libexec/ and into bin/
mkdir -p "$PREFIX/bin"
mv "$PREFIX/libexec/assemblytics/Assemblytics" "$PREFIX/bin/"
