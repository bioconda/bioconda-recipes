set -e
set -x

wget https://github.com/BMCV/SuperDSM/archive/refs/tags/v$1.tar.gz -qO- | tar -zxf -
mv SuperDSM-$1/tests ./
python -m unittest -v tests
