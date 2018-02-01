#!/bin/bash
set -e

cp LICENSE $PREFIX/
cp README $PREFIX/

mkdir -p "$PREFIX/bin"
cp bin/*.py $PREFIX/bin/

# Short wrapper script (replacement for author provided script)
# which sets DEEPSIG_ROOT (for finding model files) and
# PYTHONLIB (for finding the deepsiglib/*.py files).
cat > $PREFIX/bin/runDeepSig.sh <<EOF
#!/bin/bash
export DEEPSIG_ROOT=$PREFIX
export KERAS_BACKEND=tensorflow
PYTHONPATH=$PREFIX python $PREFIX/bin/deepsig.py "\$@"
EOF
chmod a+x $PREFIX/bin/runDeepSig.sh

mkdir -p "$PREFIX/deepsiglib"
cp deepsig/lib/python2.7/site-packages/deepsiglib/*.py $PREFIX/deepsiglib/

mkdir -p "$PREFIX/models"
cp -r models/ $PREFIX/models/
