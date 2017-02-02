cd lib/python

CONDA_PYTHON=$(conda info --root)/bin/python
$PYTHON ${CONDA_PYTHON} ${RECIPE_DIR}/setup.py install