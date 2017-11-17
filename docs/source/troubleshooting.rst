Troubleshooting failed recipes
------------------------------

.. _reading-logs:

Reading bioconda-utils logs on Travis-CI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
For successfully-built recipes, bioconda-utils will report build start/success
and test start/success. If a recipe fails, an error log message starting with
`BIOCONDA BUILD FAIL` will be printed. After that will be some verbose output.
That output is the captured, merged stdout and stderr from running conda-build
on that recipe.

Usually the easiest thing to do is grep for `BIOCONDA BUILD FAIL`, and start
reading the output below that line. The stdout and stderr for that failed build
will end with the next `BIOCONDA` log line, likely a `BIOCONDA BUILD START` or
`BIOCONDA BUILD SUMMARY` line.

At the end of the log are `BIOCONDA BUILD SUMMARY` lines which indicate how
many recipes were built successfully, how many failed, and how many were
skipped because one of their dependencies failed to build in this run.

Here's an annotated example build log to help familiarize yourself with log output::


    =============================================================================
    ## This is the command sent to bioconda-build for reproducing locally if
    ## needed
    =============================================================================

    bioconda-utils build recipes config.yml --docker --loglevel=info --mulled-test



    =============================================================================
    ## bioconda-utils pulls a docker image and builds a custom one. Any issues
    ## with docker will be reported here; this build went fine.
    =============================================================================

    INFO bioconda_utils.docker_utils:_pull_image(295): BIOCONDA DOCKER: Pulling
    docker image condaforge/linux-anvil
    INFO bioconda_utils.docker_utils:_pull_image(301): BIOCONDA DOCKER: Done
    pulling image
    INFO bioconda_utils.docker_utils:_build_image(334): BIOCONDA DOCKER: Built
    docker image tag=tmp-bioconda-builder



    =============================================================================
    ## A list of recipes that are blacklisted. This example log comes
    ## from a time when we were re-building lots of R packages and had to
    ## prevent some from building until their prerequisites were built.
    ##
    ## If a recipe is on this list, it will not get built.
    ###
    =============================================================================

    INFO bioconda_utils.build:build_recipes(198): blacklist: autoconf,
    bcbio-rnaseq, bioconductor-basic4cseq, bioconductor-biovizbase,
    bioconductor-bubbletree, bioconductor-bumphunter, bioconductor-cexor,
    bioconductor-chipcomp, bioconductor-chipseeker, bioconductor-clusterprofiler,
    bioconductor-cummerbund, bioconductor-dada2, bioconductor-deseq2/1.10.1,
    bioconductor-dexseq, bioconductor-diffbind, bioconductor-dose,
    bioconductor-ebseq, bioconductor-flowai, bioconductor-fourcseq,
    bioconductor-genelendatabase/1.6.0, bioconductor-genomation,
    bioconductor-ggbio, bioconductor-iranges/2.4.6, bioconductor-iranges/2.4.7,
    bioconductor-isomirs, bioconductor-jmosaics, bioconductor-limma/3.26.7,
    bioconductor-limma/3.28.2, bioconductor-limma/3.28.6, bioconductor-made4,
    bioconductor-minfi, bioconductor-mmdiff, bioconductor-mosaics,
    bioconductor-phyloseq, bioconductor-piano, bioconductor-qdnaseq,
    bioconductor-s4vectors/0.8.7, bioconductor-shortread,
    bioconductor-summarizedexperiment/1.0.2, bioconductor-systempiper,
    bioconductor-variantannotation, cap-mirseq, gvcftools, lefse, mgkit,
    poretools/0.5.0, poretools/0.5.1, r-batchjobs, r-catools, r-dorng, r-gmd,
    r-gplots, r-gsalib, r-hdrcde, r-knitr, r-knitrbootstrap, r-ks, r-mixomics,
    r-mutationalpatterns, r-mutoss, r-phonr, r-rainbow, r-readr, r-rmarkdown,
    r-sartools/1.2.0, r-sendmailr, r-spp, r-vegan/2.3_0, r-vegan/2.3_3,
    r-vegan/2.3_4, rpy2, rsem, triform2



    =============================================================================
    ## bioconda-utils checks each recipe to see if that version already exists
    ## on the ibioconda channel. This is a comprehensive check, and takes a
    ## couple of minutes. Here there were 1735 recipes to check.
    =============================================================================

    INFO bioconda_utils.build:build_recipes(233): Filtering recipes
    Filtering 1735 of 1735 (100.0%) recipes/zifa



    =============================================================================
    ## A report of what recipes made it through the filter. This is the total
    ## set of recipes to build across all sub-DAGs.
    =============================================================================

    INFO bioconda_utils.build:build_recipes(250): Building and testing 8 recipes in
    total
    INFO bioconda_utils.build:build_recipes(251): Recipes to build:
    bioconductor-cummerbund
    bioconductor-txdb.mmusculus.ucsc.mm10.ensgene
    bioconductor-goseq
    bioconductor-txdb.hsapiens.ucsc.hg19.knowngene
    bioconductor-txdb.dmelanogaster.ucsc.dm3.ensgene
    bioconductor-genelendatabase
    bioconductor-csaw
    bioconductor-organismdbi



    =============================================================================
    ## A report of what recipes will be built in *this* sub-DAG. The other 3
    ## will be built in parallel in subdag 1.
    =============================================================================

    INFO bioconda_utils.build:build_recipes(288): Building and testing subdag 0 of
    2 (5 recipes)



    =============================================================================
    ## Starting the build of the bioconductor-csaw package, using the environment
    ## specified.
    =============================================================================

    INFO bioconda_utils.build:build(57): BIOCONDA BUILD START
    recipes/bioconductor-csaw, env:
    CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1



    =============================================================================
    ## We didn't get very far, the first recipe failed!
    =============================================================================

    ERROR bioconda_utils.build:build(111): BIOCONDA BUILD FAILED
    recipes/bioconductor-csaw,
    CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1



    =============================================================================
    ## A report of the commands used to build the recipe under docker. This
    ## includes information on which paths were exported to the container to help with
    ## troubleshooting.
    =============================================================================

    ERROR bioconda_utils.build:build(112): COMMAND: ['docker', 'run', '--net',
    'host', '-v', '/tmp/tmphs0khbp_/build_script.bash:/opt/build_script.bash',
    '-v', '/anaconda/conda-bld:/opt/host-conda-bld', '-v',
    '/home/travis/build/daler/bioconda-recipes/recipes/bioconductor-csaw:/opt/recipe',
    '-e', 'CONDA_BOOST=1.60', '-e', 'CONDA_GMP=5.1', '-e', 'CONDA_GSL=1.16', '-e',
    'CONDA_PERL=5.22.0', '-e', 'CONDA_R=3.3.1', '-e', 'CONDA_NCURSES=5.9', '-e',
    'CONDA_NPY=110', '-e', 'CONDA_PY=27', 'tmp-bioconda-builder', '/bin/bash',
    '/opt/build_script.bash']



    =============================================================================
    ## The start of the merged stdout and stderr for building this recipe.
    ##
    ## That first part about bash not being able to set terminal process group or
    ## job control can be ignored. It's related to how the docker container is run,
    ## and is expected.
    =============================================================================

    ERROR bioconda_utils.build:build(113): STDOUT+STDERR: bash: cannot set terminal
    process group (-1): Inappropriate ioctl for device
    bash: no job control in this shell



    =============================================================================
    ## This is the actual start of the error log...
    ## The first part shows the updating of conda-build that happens in the docker
    ## container at the start of the build:
    =============================================================================

    Fetching package metadata .........
    Solving package specifications: ..........
    Package plan for installation in environment /opt/conda:
    The following packages will be downloaded:
        package                    |            build
        ---------------------------|-----------------
        conda-build-2.0.7          |           py35_0         275 KB  defaults
    The following packages will be UPDATED:
        conda:       4.1.11-py35_1 conda-forge --> 4.1.12-py35_0 conda-forge
        conda-build: 2.0.4-py35_0  defaults    --> 2.0.7-py35_0  defaults   
    Proceed ([y]/n)? 
    Using Anaconda Cloud api site https://api.anaconda.org
    Fetching packages ...
    conda-build-2. 100% |###############################| Time: 0:00:00   5.79 MB/s
    Extracting packages ...
    [      COMPLETE      ]|##################################################| 100%
    Unlinking packages ...
    [      COMPLETE      ]|##################################################| 100%
    Linking packages ...
    [      COMPLETE      ]|##################################################| 100%



    =============================================================================
    ## Now comes the building of the package.
    ##
    ## First is a list of the packages that will be downloaded along with what
    ## channel they are coming from. This is useful for making sure your recipes is
    ## pulling in dependencies from the right place.
    =============================================================================

    BUILD START: bioconductor-csaw-1.6.1-r3.3.1_0
    updating index in: /opt/conda/conda-bld/linux-64
    updating index in: /opt/conda/conda-bld/noarch
    The following packages will be downloaded:
        package                    |            build
        ---------------------------|-----------------
        bzip2-1.0.6                |                3          83 KB  defaults
        icu-54.1                   |                0        11.3 MB  defaults
        jbig-2.1                   |                0          29 KB  defaults
        jpeg-8d                    |                2         806 KB  defaults
        libffi-3.2.1               |                0          36 KB  defaults
        libgcc-5.2.0               |                0         1.1 MB  defaults

    =============================================================================
    ## ... ommitting a lot of packages here for brevity....
    =============================================================================

        r-snow-0.4_1               |         r3.3.1_0          62 KB  bioconda
        r-futile.logger-1.4.1      |         r3.3.1_0          84 KB  bioconda
        bioconductor-biocparallel-1.6.6|         r3.3.1_0         655 KB  bioconda
        bioconductor-rsamtools-1.24.0|         r3.3.1_0         3.2 MB  bioconda
        bioconductor-genomicalignments-1.8.4|         r3.3.1_0         1.5 MB  bioconda
        bioconductor-rtracklayer-1.32.2|         r3.3.1_1         1.9 MB  bioconda
        bioconductor-genomicfeatures-1.24.5|         r3.3.1_0         1.1 MB  bioconda
        ------------------------------------------------------------



    =============================================================================
    ## This section repeats pretty much the same information, listing the packages
    ## to be installed in order to build the package.
    =============================================================================

                                               Total:       143.9 MB
    The following NEW packages will be INSTALLED:
        bioconductor-annotationdbi:        1.34.4-r3.3.1_1   bioconda
        bioconductor-biobase:              2.32.0-r3.3.1_0   bioconda
        bioconductor-biocgenerics:         0.18.0-r3.3.1_0   bioconda
        bioconductor-biocparallel:         1.6.6-r3.3.1_0    bioconda
    =============================================================================
    ## ... ommitting a lot of packages here for brevity....
    =============================================================================
        ncurses:                           5.9-8             defaults
        openssl:                           1.0.2j-0          defaults
        pango:                             1.39.0-1          defaults
    Using Anaconda Cloud api site https://api.anaconda.org



    =============================================================================
    ## You may see this warning especially when building R packages. It has to do
    ## with how conda used to work and how it works now. You can ignore the
    ## "placeholder" warnings and path padding..
    =============================================================================

    WARNING:/opt/conda/lib/python3.5/site-packages/conda_build/build.py:Build prefix failed with prefix length 255
    WARNING:/opt/conda/lib/python3.5/site-packages/conda_build/build.py:Error was: 
    WARNING:/opt/conda/lib/python3.5/site-packages/conda_build/build.py:ERROR:
    placeholder
    '/home/ray/r_3_3_1-x64-3.5/envs/_build_placehold_placehold_placehold_placehold_pl'
    too short in: ncurses-5.9-8
    WARNING:/opt/conda/lib/python3.5/site-packages/conda_build/build.py:One or more
    of your package dependencies needs to be rebuilt with a longer prefix length.
    WARNING:/opt/conda/lib/python3.5/site-packages/conda_build/build.py:Falling
    back to legacy prefix length of 80 characters.
    WARNING:/opt/conda/lib/python3.5/site-packages/conda_build/build.py:Your
    package will not install into prefixes > 80 characters.
    + source /opt/conda/bin/activate
    /opt/conda/conda-bld/_b_env_placehold_placehold_placehold_placehold_placehold_pl



    =============================================================================
    ## This is finally the part where the build.sh script is run...
    =============================================================================

    + mv DESCRIPTION DESCRIPTION.old
    + grep -v '^Priority: ' DESCRIPTION.old
    +
    /opt/conda/conda-bld/_b_env_placehold_placehold_placehold_placehold_placehold_pl/bin/R
    CMD INSTALL --build .
    * installing to library
    ‘/opt/conda/conda-bld/_b_env_placehold_placehold_placehold_placehold_placehold_pl/lib/R/library’



    =============================================================================
    ##
    ## THIS is finally the error we got. This is the thing we have to fix in
    ## the recipe. In this case it was a missing dependency.
    ##
    =============================================================================

    ERROR: dependency ‘Rhtslib’ is not available for package ‘csaw’



    =============================================================================
    ## conda-build then does some cleaning up. The remainder here is generally not
    ## useful for troubleshooting recipes.
    =============================================================================

    * removing
    ‘/opt/conda/conda-bld/_b_env_placehold_placehold_placehold_placehold_placehold_pl/lib/R/library/csaw’
        pcre:                              8.39-0            defaults
        pixman:                            0.32.6-0          defaults
        r:                                 3.3.1-r3.3.1_0    r       
        r-base:                            3.3.1-3           r       
        r-bitops:                          1.0_6-r3.3.1_2    r       

    =============================================================================
    ## ...omitting for brevity...
    =============================================================================

        tk:                                8.5.18-0          defaults
        xz:                                5.2.2-0           defaults
        zlib:                              1.2.8-3           defaults




    =============================================================================
    ## conda-build actually tries to test the package even if it failed building.
    ## We now expect it to fail, so this part is not that meaningful
    =============================================================================

    updating index in: /opt/conda/conda-bld/linux-64
    updating index in: /opt/conda/conda-bld/noarch
    The following NEW packages will be INSTALLED:
        bioconductor-annotationdbi:        1.34.4-r3.3.1_1   bioconda
        bioconductor-biobase:              2.32.0-r3.3.1_0   bioconda
        bioconductor-biocgenerics:         0.18.0-r3.3.1_0   bioconda
        readline:                          6.2-2             defaults

    =============================================================================
    ## ...omitting for brevity...
    =============================================================================

        tk:                                8.5.18-0          defaults
        xz:                                5.2.2-0           defaults
        zlib:                              1.2.8-3           defaults

    Source cache directory is: /opt/conda/conda-bld/src_cache
    Downloading source to cache: csaw_1.6.1.tar.gz
    Downloading http://bioconductor.org/packages/3.3/bioc/src/contrib/csaw_1.6.1.tar.gz
    Success
    Extracting download
    Package: bioconductor-csaw-1.6.1-r3.3.1_0
    source tree in: /opt/conda/conda-bld/work/csaw
    Command failed: /bin/bash -x -e /opt/conda/conda-bld/work/csaw/conda_build.sh



    =============================================================================
    ## Now the other recipes will be built. In this case they all worked. Each
    ## recipe has a BIOCONDA BUILD START, BIOCONDA BUILD SUCCESS, BIOCONDA TEST START
    ## and BIOCONDA TEST SUCCESS line for each unique environment (here, these
    ## recipes only are built for a single environment).
    ##
    =============================================================================

    INFO bioconda_utils.build:build(57): BIOCONDA BUILD START recipes/bioconductor-txdb.mmusculus.ucsc.mm10.ensgene, env: CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(106): BIOCONDA BUILD SUCCESS /anaconda/conda-bld/linux-64/bioconductor-txdb.mmusculus.ucsc.mm10.ensgene-3.2.2-r3.3.1_0.tar.bz2, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(123): BIOCONDA TEST START via mulled-build recipes/bioconductor-txdb.mmusculus.ucsc.mm10.ensgene, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    updating index in: /anaconda/conda-bld/linux-64
    INFO bioconda_utils.build:build(128): BIOCONDA TEST SUCCESS recipes/bioconductor-txdb.mmusculus.ucsc.mm10.ensgene, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(57): BIOCONDA BUILD START recipes/bioconductor-genelendatabase, env: CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(106): BIOCONDA BUILD SUCCESS /anaconda/conda-bld/linux-64/bioconductor-genelendatabase-1.10.0-r3.3.1_0.tar.bz2, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(123): BIOCONDA TEST START via mulled-build recipes/bioconductor-genelendatabase, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    updating index in: /anaconda/conda-bld/linux-64
    INFO bioconda_utils.build:build(128): BIOCONDA TEST SUCCESS recipes/bioconductor-genelendatabase, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(57): BIOCONDA BUILD START recipes/bioconductor-goseq/1.22.0, env: CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(106): BIOCONDA BUILD SUCCESS /anaconda/conda-bld/linux-64/bioconductor-goseq-1.22.0-r3.3.1_0.tar.bz2, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(123): BIOCONDA TEST START via mulled-build recipes/bioconductor-goseq/1.22.0, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    updating index in: /anaconda/conda-bld/linux-64
    INFO bioconda_utils.build:build(128): BIOCONDA TEST SUCCESS recipes/bioconductor-goseq/1.22.0, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(57): BIOCONDA BUILD START recipes/bioconductor-txdb.dmelanogaster.ucsc.dm3.ensgene, env: CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(106): BIOCONDA BUILD SUCCESS /anaconda/conda-bld/linux-64/bioconductor-txdb.dmelanogaster.ucsc.dm3.ensgene-3.2.2-r3.3.1_0.tar.bz2, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    INFO bioconda_utils.build:build(123): BIOCONDA TEST START via mulled-build recipes/bioconductor-txdb.dmelanogaster.ucsc.dm3.ensgene, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1
    updating index in: /anaconda/conda-bld/linux-64
    INFO bioconda_utils.build:build(128): BIOCONDA TEST SUCCESS recipes/bioconductor-txdb.dmelanogaster.ucsc.dm3.ensgene, CONDA_BOOST=1.60;CONDA_GMP=5.1;CONDA_GSL=1.16;CONDA_NCURSES=5.9;CONDA_NPY=110;CONDA_PERL=5.22.0;CONDA_PY=27;CONDA_R=3.3.1



    =============================================================================
    ## At the end is a report summarizing what worked and what failed so you know
    ## what to look for up in the main log.
    =============================================================================

    ERROR bioconda_utils.build:build_recipes(340): BIOCONDA BUILD SUMMARY: of 5
    recipes, 1 failed and 0 were skipped. Details of recipes and environments
    follow.
    ERROR bioconda_utils.build:build_recipes(346): BIOCONDA BUILD SUMMARY: while
    the entire build failed, the following recipes were built successfully:
    recipes/bioconductor-txdb.mmusculus.ucsc.mm10.ensgene
    recipes/bioconductor-genelendatabase
    recipes/bioconductor-goseq/1.22.0
    recipes/bioconductor-txdb.dmelanogaster.ucsc.dm3.ensgene
    ERROR bioconda_utils.build:build_recipes(351): BIOCONDA BUILD SUMMARY: FAILED
    recipe bioconductor-csaw-1.6.1-r3.3.1_0.tar.bz2, environment
    CONDA_GMP=5.1;CONDA_PY=27;CONDA_BOOST=1.60;CONDA_R=3.3.1;CONDA_GSL=1.16;CONDA_PERL=5.22.0;CONDA_NCURSES=5.9;CONDA_NPY=110



    =============================================================================
    ## This part about travis_jigger is referring to a trick we use to prevent the
    ## build from timing out to quickly and can be ignored.
    =============================================================================
    /home/travis/build.sh: line 141:  3146 Terminated              travis_jigger $! $timeout $cmd



    =============================================================================
    ## This is the final error from travis-ci telling us that our test script
    ## (scripts/travis-run.sh) did not exit with exit code 0 and is therefore
    ## considered a failed test.
    =============================================================================

    The command "travis_wait 75 scripts/travis-run.sh" exited with 1.
    Done. Your build exited with 1.

HTTP 500 errors
~~~~~~~~~~~~~~~
Sometimes recipes fail for reasons outside our control. For example, if
anaconda.org returns an HTTP 500 error, that has nothing to do with the recipe
but with anaconda.org's servers. In this case, you can either restart the build
for that sub-DAG on travis-ci, or close the PR and then immediately re-open it
to trigger a re-build.


HTTP 404 errors
~~~~~~~~~~~~~~~
HTTP 404 errors can happen if a url used for a recipe was not stable. In this
case the solution is to track down a stable URL. For example this problem
happened frequently with Bioconductor recipes that were up-to-date as of the
current Bioconductor release, but when a new Bioconductor version came out the
links would not work.

The solution to this is the `Cargo Port
<https://depot.galaxyproject.org/software/>`_, developed and maintained by the
`Galaxy <https://galaxyproject.org/>`_ team. The Galaxy Jenkins server performs
daily archives of the source code of packages in ``bioconda``, and makes these
tarballs permanently available in Cargo Port. If you try rebuilding a recipe
and the source seems to have disappeared, do the following:

- search for the package and version at https://depot.galaxyproject.org/software/

- add the URL listed in the "Package Version" column to your ``meta.yaml``
  file as another entry in the ``source: url`` section.

- add the corresponding sha256 checksum displayed upon clicking the Info icon
  in the "Help" column to the ``source:`` section.

For example, if this stopped working:

.. code:: yaml

    source:
      fn: argh-0.26.1.tar.gz
      url: https://pypi.python.org/packages/source/a/argh/argh-0.26.1.tar.gz
      md5: 5a97ce2ae74bbe3b63194906213f1184

then change it to this:

.. code:: yaml

    source:
      fn: argh-0.26.1.tar.gz
      url:
        - https://pypi.python.org/packages/source/a/argh/argh-0.26.1.tar.gz
        - https://depot.galaxyproject.org/software/argh/argh_0.26.1_src_all.tar.gz
      md5: 5a97ce2ae74bbe3b63194906213f1184
      sha256: 06a7442cb9130fb8806fe336000fcf20edf1f2f8ad205e7b62cec118505510db


.. _zlib:

ZLIB errors
~~~~~~~~~~~
When building the package, you may get an error saying that zlib.h can't be
found -- despite having zlib listed in the dependencies. The reason is that the
location of `zlib` often has to be specified in the `build.sh` script, which
can be done like this:

.. code-block:: bash

    export CFLAGS="-I$PREFIX/include"
    export LDFLAGS="-L$PREFIX/lib"

Or sometimes:

.. code-block:: bash

    export CPATH=${PREFIX}/include

Sometimes Makefiles may specify these locations, in which case they need to be
edited. See the `samtools` recipe for an example of this. It may take some
tinkering to get the recipe to build; if it doesn't seem to work then please
submit an issue or notify `@bioconda/core` for advice.


``/usr/bin/perl`` or ``/usr/bin/python`` not found
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Often a tool hard-codes the shebang line as, e.g., ``/usr/bin/perl`` rather
than the more portable ``/usr/bin/env perl``. To fix this, use ``sed`` in the
build script to edit the lines.

Here is an example that will replace the first line of a file
``$PREFIX/bin/alocal`` with the proper shebang line ::

    sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal

(note the ``-i.bak``, which is needed to support both Linux and OSX versions of
``sed``).

It turns out that the version of `autoconf` that is packaged in the defaults
channel still uses the hard-coded Perl. So if a tool uses `autoconf` for
building, it is likely you will see this error and it will need some ``sed``
commands. See `here
<https://github.com/bioconda/bioconda-recipes/blob/4bc02d7b4d784c923481d8808ed83e048c01d3bb/recipes/exparna/build.sh>`_
for an example to work from.

Troubleshooting failed ``mulled-build`` tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
After conda sucessfully builds and tests a package, we then perform a more
stringent test in a minimal Docker container using ``mulled-build``. Notably,
this container does not have conda and has very few libraries. So this test can
catch issues that the default conda test cannot. However the extra layer of
abstraction makes it difficult to troubleshoot problems with the recipe. If the
conda-build test works but the mulled-build test fails try these steps:

- Run ``simulate-travis.py`` locally with ``--loglevel=debug``
- Look carefully at the output from ``mulled-build`` to look for Docker hashes,
  and cross-reference with the output of ``docker images | head`` to figure out
  the hash of the container used.
- Start up an interactive docker container, ``docker run -it $hash``. You can
  now try running the tests in the recipe that failed, or otherwise poke around
  in the running container to see what the problem was.


Using the extended image
~~~~~~~~~~~~~~~~~~~~~~~~
For the vast majority of recipes, we use a minimal BusyBox container for
testing and to upload to quay.io. This allows us to greatly reduce the size of
images, but there are some packages that are not compatible with the minimal
container. To support these cases, we offer the ability to in special cases use
an "extended base" container. This container is maintained at
https://github.com/bioconda/bioconda-extended-base-image and is automatically
built by DockerHub when Dockerfile is updated in the GitHub repo.

Please note that **this is not a general solution to packaging issues**, and
should only be used as a last resort. Cases where the extended base has been
needed are:

- Unicode support is required (especially if a package uses the ``click``
  Python package under Python 3; see for example comments `here
  <https://github.com/bioconda/bioconda-recipes/pull/5541#issuecomment-323755800>`_
  and `here
  <https://github.com/bioconda/bioconda-recipes/pull/6094#issuecomment-332272936>`_).
- ``libGL.so.1`` dependency
- ``openssl`` dependency, e.g., through ``openmpi``

To use the extended container, add the following to a recipe's ``meta.yaml``:

.. code-block:: yaml

    extra:
      container:
        extended-base: True


