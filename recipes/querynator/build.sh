
echo " === Start build"
${PYTHON} -m pip install . -vv
echo "Pip install done - now adjusting the library paths"
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
echo "civicpy is not available from conda ... ... ..."
${PYTHON} -m pip uninstall civicpy
${PYTHON} -m pip install https://files.pythonhosted.org/packages/01/6f/ffc1989427467eb2f8728387f9377c454f83ec42c57e1a995769d3166c66/civicpy-3.0.0-py3-none-any.whl -vv
echo " === Build finished"