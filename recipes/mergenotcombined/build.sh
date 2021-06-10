echo "mergeNotCombined compilation"
make CPP=${CXX}
mkdir -p $PREFIX/bin
cp mergeNotCombined $PREFIX/bin
chmod +x $PREFIX/bin/mergeNotCombined
echo "Installation successful."

