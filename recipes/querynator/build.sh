
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
${PYTHON} -m pip install civicpy -vv
echo " === Build finished"