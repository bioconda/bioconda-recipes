VERSION="0.2.4"
PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}{1}".format(*version))'`
pip install https://files.pythonhosted.org/packages/cp$PYTHON_VERSION/l/lib_pod5/lib_pod5-$VERSION-cp$PYTHON_VERSION-cp$PYTHON_VERSION-manylinux_2_17_x86_64.manylinux2014_x86_64.whl