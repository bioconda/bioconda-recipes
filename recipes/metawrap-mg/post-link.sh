CHECKM_DIR="$( find "${PREFIX}/lib" -type d -name checkm )"
find "${CHECKM_DIR}" -type f -name DATA_CONFIG \
	-exec chmod 777 {} \;
