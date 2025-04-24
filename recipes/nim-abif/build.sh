
set -euxo pipefail

mkdir -p $PREFIX/bin

nimble build -y --verbose
mv ./bin/* "$PREFIX"/bin/
