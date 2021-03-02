echo """    conda config --add channels defaults
    conda config --add channels biconda
    conda config --add channels conda-forge """ >> "${PREFIX}/.messages.txt" 2>&1

