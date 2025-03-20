echo "Removing CCT database"
CCT_DB_DIR=${PREFIX}/cct_data
if [[ -d $CCT_DB_DIR ]]; then
    rm -r $CCT_DB_DIR
fi
