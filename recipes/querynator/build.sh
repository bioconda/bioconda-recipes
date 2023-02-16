
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
# ${PYTHON} -m pip install https://files.pythonhosted.org/packages/14/d3/65e304ef565997a57f12d79257beccb57d14efc927069a3be7d3183a8acc/tensorflow-2.7.2-cp38-cp38-manylinux2010_x86_64.whl -vv
echo " === Build finished"