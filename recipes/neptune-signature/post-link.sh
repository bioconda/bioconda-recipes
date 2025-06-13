#!/usr/bin/env bash

# In an effort to work around an issue with incompatability with local Python
# packages, we create a new executable after installation and set the
# PYTHONNOUSERSITE variable to ensure local packages are not used when running
# this application. The old executable is called by the new executable.

# See:
# https://github.com/conda/conda/issues/394
# https://github.com/conda/conda/issues/448

# Moving previous executable and preserving permissions:
cp -a $PREFIX/bin/neptune $PREFIX/bin/neptune-conda

# Creating a new executable (while preserving permissions). The new executable
# will activate the previous executable:
echo "#!/usr/bin/env bash" > $PREFIX/bin/neptune
echo "export PYTHONNOUSERSITE=True" >> $PREFIX/bin/neptune
echo "$PREFIX/bin/neptune-conda \"\$@\"""" >> $PREFIX/bin/neptune
