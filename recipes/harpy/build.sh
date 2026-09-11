## build harpy
python -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

## build Go binaries
mkdir -p ${PREFIX}/bin

{
    cd harpy/utils
    go build -C stagger -o ../gih-stagger -ldflags='-s -w' stagger.go
    go build -C convert -o ../gih-convert -ldflags='-s -w' convert.go
    go build -C standardize -o ../djinn-standardize -ldflags='-s -w' standardize.go 
    #chmod +x gih-stagger gih-convert djinn-standardize
    install -m 755 gih-stagger gih-convert djinn-standardize ${PREFIX}/bin/
}

# Jupyter env fixes
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d

cat > ${PREFIX}/etc/conda/activate.d/harpy-activate.sh <<'EOF'  
export _HARPY_OLD_JUPYTER_NOTARY_DB="${JUPYTER_NOTARY_DB-__UNSET__}"  
export JUPYTER_NOTARY_DB=':memory:'  

python -m ipykernel install --prefix "${CONDA_PREFIX:?CONDA_PREFIX is required}" --name ipython-harpy \
    --display-name "Python (harpy)"
EOF
  
cat > ${PREFIX}/etc/conda/deactivate.d/harpy-deactivate.sh <<'EOF'  
if [ "${_HARPY_OLD_JUPYTER_NOTARY_DB-__UNSET__}" = "__UNSET__" ]; then  
  unset JUPYTER_NOTARY_DB  
else  
  export JUPYTER_NOTARY_DB="${_HARPY_OLD_JUPYTER_NOTARY_DB}"  
fi  
unset _HARPY_OLD_JUPYTER_NOTARY_DB  
EOF
