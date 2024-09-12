set -e

mkdir -p "$PREFIX/bin"
chmod u+x bin/*
cp -r bin/* "$PREFIX/bin"

cp -r EnsembleScripts "$PREFIX/bin"
cp -r V4Scripts "$PREFIX/bin"