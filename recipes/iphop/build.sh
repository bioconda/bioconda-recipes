echo " === Start build"
${PYTHON} -m pip install . --no-deps --no-build-isolation -vvv
echo "Pip install done - now adjusting the library paths"
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
echo "Finally - we have to provide tensorflow-decision-forests here because it's not available in conda - and also needs to do tensorflow itself because conda version not compatible with tf-df from pip ... ... ..."
${PYTHON} -m pip uninstall tensorflow
${PYTHON} -m pip install https://files.pythonhosted.org/packages/72/8a/033b584f8dd863c07aa8877c2dd231777de0bb0b1338f4ac6a81999980ee/tensorflow-2.7.0-cp38-cp38-manylinux2010_x86_64.whl -vv
# ${PYTHON} -m pip install https://files.pythonhosted.org/packages/14/d3/65e304ef565997a57f12d79257beccb57d14efc927069a3be7d3183a8acc/tensorflow-2.7.2-cp38-cp38-manylinux2010_x86_64.whl -vv
${PYTHON} -m pip install https://files.pythonhosted.org/packages/2a/78/bf49937d0d9a36a19faca28dac470a48cfe4894995a70e73f3c0c1684991/tensorflow_decision_forests-0.2.2-cp38-cp38-manylinux_2_12_x86_64.manylinux2010_x86_64.whl -vv
echo " === Build finished"
