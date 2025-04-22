echo "Installing the package"
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
echo "Making sure the env variable pointing to this database will be correctly set up when loading this conda environment"
## Set up the files needed to update the env variable (CCTYPER_DB) at each activation / deactivation
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
