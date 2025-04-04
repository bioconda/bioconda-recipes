echo "unmerge compilation"
make CPP=${CXX}
mkdir -p $PREFIX/bin
cp unmerge $PREFIX/bin
chmod +x $PREFIX/bin/unmerge
echo "Installation successful."
