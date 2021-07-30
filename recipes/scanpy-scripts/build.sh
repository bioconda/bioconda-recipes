python -m pip install . --no-deps --ignore-installed -vv
wget https://github.com/theislab/scanpy/archive/refs/tags/1.8.1.tar.gz
tar -xvzf 1.8.1.tar.gz
cd scanpy-1.8.1
wget https://raw.githubusercontent.com/ebi-gene-expression-group/scanpy-scripts/develop/scrublet.patch
patch -p1 < scrublet.patch
python -m pip install . --no-deps --ignore-installed -vv

