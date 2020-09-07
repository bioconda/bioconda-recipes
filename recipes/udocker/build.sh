#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv
mv $PREFIX/bin/udocker $PREFIX/bin/udocker.py

cat <<END >$PREFIX/bin/udocker
#!/bin/bash

UDOCKER_LIB=\$CONDA_PREFIX/lib
UDOCKER_BIN=\$CONDA_PREFIX/bin
export UDOCKER_LIB UDOCKER_BIN
\$CONDA_PREFIX/bin/udocker.py \$@
END

chmod a+x $PREFIX/bin/udocker

echo "$PKG_VERSION" >$PREFIX/lib/VERSION

