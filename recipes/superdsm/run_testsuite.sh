set -e
set -x

cd SuperDSM-$1
python -m unittest -v tests
