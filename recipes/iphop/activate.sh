export OLD_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${CONDA_PREFIX}/x86_64-conda-linux-gnu/lib/:${CONDA_PREFIX}/lib/:${LD_LIBRARY_PATH}
export OLD_PERL5LIB=$PERL5LIB
export PERL5LIB=${CONDA_PREFIX}/lib/perl5/site_perl/5.22.0:${CONDA_PREFIX}/lib/perl5/site_perl/:${PERL5LIB}
