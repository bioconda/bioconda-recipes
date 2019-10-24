./bootstrap.py /tmp/miniconda
source ~/.config/bioconda/activate

# optional linting
# bioconda-utils lint --git-range master


# from circleci:

bioconda-utils build recipes config.yml \
  --docker --mulled-test \
  --git-range master HEAD
mulled-build build-and-test mango=0.0.5--py_0 -n biocontainers --test mango-submit --help && SPARK_HOME=$SP_DIR/pyspark mango-notebook --help && make_genome --help --channels conda-forge,file:///home/circleci/project/miniconda/conda-bld,bioconda,defaults --involucro-path /home/circleci/project/miniconda/bin/involucro
# end from circleci



bioconda-utils \
    build --mulled-test  --packages mango \
    --docker

mulled-build build-and-test mango=0.0.5--py_0 -n biocontainers --test echo "SITE PACKAGES DIRECTORY" --help --channels conda-forge,file:///tmp/miniconda/miniconda/conda-bld,bioconda,defaults --involucro-path /Users/akmorrow/go/bin/involucro

mulled-build build-and-test mango=0.0.5--py_0 -n biocontainers --test "mango-submit --help && SPARK_HOME=$(python -c \"import site,os; print(os.path.join(site.getsitepackages()[0], \"pyspark\"))\" ) mango-notebook --help && make_genome --help && python -c \"import bdgenomics\" && python -c \"import bdgenomics.adam\" && python -c \"import bdgenomics.mango\" && python -c \"import modin\"" --channels conda-forge,file:///tmp/miniconda/miniconda/conda-bld,bioconda,defaults --involucro-path /Users/akmorrow/go/bin/involucro
