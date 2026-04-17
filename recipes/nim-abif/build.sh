
set -euxo pipefail

mkdir -p $PREFIX/bin

nimble build -y --verbose
nimble buildbin --verbose
mv ./bin/* "$PREFIX"/bin/
