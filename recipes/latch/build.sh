for package in lyteidl lytekit lytekitplugins-pods latch 
do
	pushd ${SRC_DIR}/${package}
	python -m pip install -vv --no-deps . 
	popd
done
