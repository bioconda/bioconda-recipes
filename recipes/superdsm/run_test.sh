set -e
set -x

echo "Running SuperDSM test suite"

python -m unittest -v tests
