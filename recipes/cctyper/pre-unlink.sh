echo "Removing CCT database"
CCT_DB_DIR=${PREFIX}/cct_data
if [[ -d $CCT_DB_DIR ]]; then
    rm -r $CCT_DB_DIR
fi
echo "Also removing the files that were setting up the relevant env variable"
for CHANGE in "activate" "deactivate"
do
    rm "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
