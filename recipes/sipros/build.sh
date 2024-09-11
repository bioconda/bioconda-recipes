set -e

mkdir -p "$PREFIX/bin"
chmod bin/*
cp -r bin/* "$PREFIX/bin"