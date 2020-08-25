Docker image digest: sha256:77555db9368056ab71b1cf317b02dc922588a496e55079896e3eb8daae1577e0
[36m====>> Spin Up Environment[0m
Build-agent version  ()
Docker Engine Version: 19.03.12
Kernel Version: Linux c8771d7a1b4f 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 x86_64 Linux
Starting container bioconda/bioconda-utils-build-env
  image is cached as bioconda/bioconda-utils-build-env, but refreshing...
latest: Pulling from bioconda/bioconda-utils-build-env
Digest: sha256:b3247e65cd21df69c9aa842d6503f0447f283f6600ed0983589748c33a8bb95b
Status: Image is up to date for bioconda/bioconda-utils-build-env:latest
  pull stats: N/A
  time to create container: 127ms
  using image bioconda/bioconda-utils-build-env@sha256:b3247e65cd21df69c9aa842d6503f0447f283f6600ed0983589748c33a8bb95b
Time to upload agent and config: 1.073145561s
Time to start containers: 394.552148ms
[36m====>> Preparing Environment Variables[0m
Using build environment variables:
  BASH_ENV=/tmp/.bash_env-localbuild-1598358681
  CI=true
  CIRCLECI=true
  CIRCLE_BRANCH=vsclust
  CIRCLE_BUILD_NUM=
  CIRCLE_JOB=build
  CIRCLE_NODE_INDEX=0
  CIRCLE_NODE_TOTAL=1
  CIRCLE_REPOSITORY_URL=https://github.com/bioconda/bioconda-recipes.git
  CIRCLE_SHA1=db004bffd8d9070efdac5ce63ebc162e6314203a
  CIRCLE_SHELL_ENV=/tmp/.bash_env-localbuild-1598358681
  CIRCLE_WORKING_DIRECTORY=~/project


The redacted variables listed above will be masked in run step output.[36m====>> Checkout code[0m
[37m  #!/bin/bash -eo pipefail
mkdir -p /root/project && cd /tmp/_circleci_local_build_repo && git ls-files | tar -T - -c | tar -x -C /root/project && cp -a /tmp/_circleci_local_build_repo/.git /root/project[0m
[36m====>> Setup ssh[0m
[37m  #!/bin/bash -eo pipefail
mkdir -p ~/.ssh
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
[0m
# github.com SSH-2.0-babeld-b447314b
[36m====>> echo ". /opt/conda/etc/profile.d/conda.sh" >> $BASH_ENV[0m
[37m  #!/bin/bash -eo pipefail
echo ". /opt/conda/etc/profile.d/conda.sh" >> $BASH_ENV[0m
[36m====>> echo "conda activate" >> $BASH_ENV[0m
[37m  #!/bin/bash -eo pipefail
echo "conda activate" >> $BASH_ENV[0m
[36m====>> Download common definitions[0m
[37m  #!/bin/bash -eo pipefail
curl -s https://raw.githubusercontent.com/bioconda/bioconda-common/master/common.sh > .circleci/common.sh
[0m
[36m====>> Setup bioconda-utils[0m
[37m  #!/bin/bash -eo pipefail
.circleci/setup.sh[0m
From https://github.com/bioconda/bioconda-recipes
 * [new branch]          master     -> __upstream__JNMBjCAV0P/master
bioconda-utils is /opt/conda/bin/bioconda-utils
From https://github.com/bioconda/bioconda-recipes
 + fa27d31c2...7548381c8 master     -> master  (forced update)
[36m====>> Linting[0m
[37m  #!/bin/bash -eo pipefail
bioconda-utils lint recipes config.yml \
--loglevel debug --full-report \
--git-range master HEAD
[0m
12:31:32 [36mBIOCONDA DEBUG[0m get_recipes(recipes, package='['*']'): *[0m
12:31:33 [33mBIOCONDA WARNING[0m No meta.yaml found in recipes/clinker. If you want to ignore this directory, add it to the blacklist.[0m
12:31:33 [32mBIOCONDA INFO[0m Considering total of 7395 recipes.[0m
12:31:33 [36mGIT DEBUG[0m Popen(['git', 'remote', 'get-url', '--all', 'origin'], cwd=/root/project, universal_newlines=False, shell=None, istream=None)[0m
12:31:33 [36mASYNCIO DEBUG[0m Using selector: EpollSelector[0m
12:31:33 [36mGIT DEBUG[0m Popen(['git', 'merge-base', 'master', 'HEAD'], cwd=/root/project, universal_newlines=False, shell=None, istream=None)[0m
12:31:33 [36mGIT DEBUG[0m Popen(['git', 'cat-file', '--batch-check'], cwd=/root/project, universal_newlines=False, shell=None, istream=<valid stream>)[0m
12:31:33 [36mGIT DEBUG[0m Popen(['git', 'diff-tree', '541c7c12a4be7207d9441f91564042d85874c1b9', 'HEAD', '-r', '--abbrev=40', '--full-index', '-M', '--raw', '--no-color'], cwd=/root/project, universal_newlines=False, shell=None, istream=None)[0m
12:31:33 [36mGIT DEBUG[0m Popen(['git', 'cat-file', '--batch'], cwd=/root/project, universal_newlines=False, shell=None, istream=<valid stream>)[0m
12:31:33 [36mGIT DEBUG[0m Popen(['git', 'merge-base', 'master', 'HEAD'], cwd=/root/project, universal_newlines=False, shell=None, istream=None)[0m
12:31:33 [32mBIOCONDA INFO[0m Constraining to 1 git modified recipes (vsclust).[0m
12:31:33 [32mBIOCONDA INFO[0m Processing 1 recipes (vsclust).[0m
All checks OK
[36m====>> Testing[0m
[37m  #!/bin/bash -eo pipefail
bioconda-utils build recipes config.yml \
--git-range master HEAD
[0m
12:31:46 [33mBIOCONDA WARNING[0m No meta.yaml found in recipes/clinker. If you want to ignore this directory, add it to the blacklist.[0m
12:31:46 [32mBIOCONDA INFO[0m Considering total of 7395 recipes.[0m
12:31:47 [32mBIOCONDA INFO[0m Constraining to 1 git modified recipes (vsclust).[0m
12:31:47 [32mBIOCONDA INFO[0m Processing 1 recipes (vsclust).[0m
12:31:47 [32mBIOCONDA INFO[0m Generating DAG[0m
12:31:47 [32mBIOCONDA INFO[0m 1 recipes to build and test: 
vsclust[0m
12:31:47 [32mBIOCONDA INFO[0m Determining expected packages for recipes/vsclust[0m
Setting build platform. This is only useful when pretending to be on another platform, such as for rendering necessary dependencies on a non-native platform. I trust that you know what you're doing.
12:31:47 [33mCONDA_BUILD WARNING[0m Setting build platform. This is only useful when pretending to be on another platform, such as for rendering necessary dependencies on a non-native platform. I trust that you know what you're doing.[0m
No numpy version specified in conda_build_config.yaml.  Falling back to default numpy value of 1.11
12:31:47 [33mCONDA_BUILD WARNING[0m No numpy version specified in conda_build_config.yaml.  Falling back to default numpy value of 1.11[0m
Adding in variants from internal_defaults
12:31:47 [32mCONDA_BUILD INFO[0m Adding in variants from internal_defaults[0m
Adding in variants from /opt/conda/conda_build_config.yaml
12:31:47 [32mCONDA_BUILD INFO[0m Adding in variants from /opt/conda/conda_build_config.yaml[0m
Adding in variants from /opt/conda/lib/python3.7/site-packages/bioconda_utils/bioconda_utils-conda_build_config.yaml
12:31:47 [32mCONDA_BUILD INFO[0m Adding in variants from /opt/conda/lib/python3.7/site-packages/bioconda_utils/bioconda_utils-conda_build_config.yaml[0m
Attempting to finalize metadata for vsclust
12:32:05 [32mCONDA_BUILD INFO[0m Attempting to finalize metadata for vsclust[0m
Collecting package metadata (repodata.json): ...working... done
Solving environment: ...working... done
Collecting package metadata (repodata.json): ...working... done
Solving environment: ...working... done
Collecting package metadata (repodata.json): ...working... done
Solving environment: ...working... done
12:36:44 [32mBIOCONDA INFO[0m BUILD START recipes/vsclust[0m
12:36:44 [32mBIOCONDA INFO[0m (COMMAND) /opt/conda/bin/conda build --override-channels --no-anaconda-upload -c conda-forge -c bioconda -c defaults -e /opt/conda/conda_build_config.yaml -e /opt/conda/lib/python3.7/site-packages/bioconda_utils/bioconda_utils-conda_build_config.yaml recipes/vsclust/meta.yaml[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) /opt/conda/lib/python3.7/site-packages/conda_build/cli/main_build.py:376: UserWarning: RECIPE_PATH received is a file. File: recipes/vsclust/meta.yaml[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) It should be a path to a folder.[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) Forcing conda-build to use the recipe file.[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR)   UserWarning[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) No numpy version specified in conda_build_config.yaml.  Falling back to default numpy value of 1.11[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) WARNING:conda_build.metadata:No numpy version specified in conda_build_config.yaml.  Falling back to default numpy value of 1.11[0m
12:36:45 [32mBIOCONDA INFO[0m (OUT) Adding in variants from internal_defaults[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.variants:Adding in variants from internal_defaults[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.variants:Adding in variants from /opt/conda/conda_build_config.yaml[0m
12:36:45 [32mBIOCONDA INFO[0m (OUT) Adding in variants from /opt/conda/conda_build_config.yaml[0m
12:36:45 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.variants:Adding in variants from /opt/conda/lib/python3.7/site-packages/bioconda_utils/bioconda_utils-conda_build_config.yaml[0m
12:36:45 [32mBIOCONDA INFO[0m (OUT) Adding in variants from /opt/conda/lib/python3.7/site-packages/bioconda_utils/bioconda_utils-conda_build_config.yaml[0m
12:36:46 [32mBIOCONDA INFO[0m (OUT) Attempting to finalize metadata for vsclust[0m
12:36:46 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.metadata:Attempting to finalize metadata for vsclust[0m
12:37:31 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
12:37:36 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
.12:37:51 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
12:38:10 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
12:38:25 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
.12:39:43 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
12:39:44 [32mBIOCONDA INFO[0m (OUT) BUILD START: ['vsclust-0.86-r36h4333106_0.tar.bz2'][0m
.12:40:00 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
.12:41:22 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) [0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) ## Package Plan ##[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) [0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)   environment location: /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) [0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) [0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) The following NEW packages will be INSTALLED:[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT) [0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     _libgcc_mutex:             0.1-conda_forge            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     _openmp_mutex:             4.5-1_gnu                  conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     _r-mutex:                  1.0.1-anacondar_1          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     binutils_impl_linux-64:    2.34-h53a641e_7            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     binutils_linux-64:         2.34-hc952b39_20           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-biobase:      2.46.0-r36h516909a_0       bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-biocgenerics: 0.32.0-r36_0               bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-dyndoc:       1.64.0-r36_0               bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-limma:        3.42.0-r36h516909a_0       bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-mfuzz:        2.46.0-r36_0               bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-qvalue:       2.18.0-r36_1               bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-tkwidgets:    1.64.0-r36_0               bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bioconductor-widgettools:  1.64.0-r36_0               bioconda[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bwidget:                   1.9.14-0                   conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     bzip2:                     1.0.8-h516909a_3           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     c-ares:                    1.16.1-h516909a_3          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     ca-certificates:           2020.6.20-hecda079_0       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     cairo:                     1.16.0-h3fc0475_1005       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     certifi:                   2020.6.20-py38h32f6830_0   conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     curl:                      7.71.1-he644dc0_5          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     fontconfig:                2.13.1-h1056068_1002       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     freetype:                  2.10.2-he06d7ca_0          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     fribidi:                   1.0.10-h516909a_0          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gcc_impl_linux-64:         7.5.0-hd420e75_6           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gcc_linux-64:              7.5.0-h09487f9_20          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gettext:                   0.19.8.1-hc5be6a0_1002     conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gfortran_impl_linux-64:    7.5.0-hdf63c60_6           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gfortran_linux-64:         7.5.0-h09487f9_20          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     glib:                      2.65.0-h6f030ca_0          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     graphite2:                 1.3.13-he1b5a44_1001       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gsl:                       2.6-h294904e_0             conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gxx_impl_linux-64:         7.5.0-hdf63c60_6           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     gxx_linux-64:              7.5.0-h09487f9_20          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     harfbuzz:                  2.7.1-hee91db6_0           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     icu:                       67.1-he1b5a44_0            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     jpeg:                      9d-h516909a_0              conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     krb5:                      1.17.1-hfafb76e_2          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     ld_impl_linux-64:          2.34-h53a641e_7            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libblas:                   3.8.0-17_openblas          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libcblas:                  3.8.0-17_openblas          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libcurl:                   7.71.1-hcdd3856_5          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libedit:                   3.1.20191231-he28a2e2_2    conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libev:                     4.33-h516909a_0            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libffi:                    3.2.1-he1b5a44_1007        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libgcc-ng:                 9.3.0-h24d8f2e_16          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libgfortran-ng:            7.5.0-hdf63c60_16          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libgomp:                   9.3.0-h24d8f2e_16          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libiconv:                  1.16-h516909a_0            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     liblapack:                 3.8.0-17_openblas          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libnghttp2:                1.41.0-hab1572f_1          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libopenblas:               0.3.10-pthreads_hb3c22a3_4 conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libpng:                    1.6.37-hed695b0_2          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libssh2:                   1.9.0-hab1572f_5           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libstdcxx-ng:              9.3.0-hdf63c60_16          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libtiff:                   4.1.0-hc7e4089_6           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libuuid:                   2.32.1-h14c3975_1000       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libwebp-base:              1.1.0-h516909a_3           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libxcb:                    1.13-h14c3975_1002         conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     libxml2:                   2.9.10-h68273f3_2          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     lz4-c:                     1.9.2-he1b5a44_3           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     make:                      4.3-h516909a_0             conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     ncurses:                   6.2-he1b5a44_1             conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     openssl:                   1.1.1g-h516909a_1          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     pango:                     1.42.4-h7062337_4          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     pcre:                      8.44-he1b5a44_0            conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     pip:                       20.2.2-py_0                conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     pixman:                    0.38.0-h516909a_1003       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     pthread-stubs:             0.4-h14c3975_1001          conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     python:                    3.8.5-h1103e12_5_cpython   conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     python_abi:                3.8-1_cp38                 conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-assertthat:              0.2.1-r36h6115d3f_2        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-backports:               1.1.9-r36hcdcec82_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-base:                    3.6.3-he766273_3           conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-callr:                   3.4.3-r36h6115d3f_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-class:                   7.3_17-r36hcdcec82_1       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-cli:                     2.0.2-r36h6115d3f_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-colorspace:              1.4_1-r36hcdcec82_2        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-crayon:                  1.3.4-r36h6115d3f_1003     conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-desc:                    1.2.0-r36h6115d3f_1003     conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-digest:                  0.6.25-r36h0357c0b_2       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-e1071:                   1.7_3-r36h0357c0b_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-ellipsis:                0.3.1-r36hcdcec82_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-evaluate:                0.14-r36h6115d3f_2         conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-fansi:                   0.4.1-r36hcdcec82_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-farver:                  2.0.3-r36h0357c0b_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-ggplot2:                 3.3.2-r36h6115d3f_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-glue:                    1.4.1-r36hcdcec82_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-gtable:                  0.3.0-r36h6115d3f_3        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-isoband:                 0.2.2-r36h0357c0b_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-labeling:                0.3-r36h6115d3f_1003       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-lattice:                 0.20_41-r36hcdcec82_2      conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-lifecycle:               0.2.0-r36h6115d3f_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-magrittr:                1.5-r36h6115d3f_1003       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-mass:                    7.3_52-r36hcdcec82_0       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-matrix:                  1.2_18-r36h7fa42b6_3       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-matrixstats:             0.56.0-r36hcdcec82_1       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-mgcv:                    1.8_32-r36h7fa42b6_0       conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-munsell:                 0.5.0-r36h6115d3f_1003     conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-nlme:                    3.1_149-r36h9bbef5b_0      conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-pillar:                  1.4.6-r36h6115d3f_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-pkgbuild:                1.1.0-r36h6115d3f_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-pkgconfig:               2.0.3-r36h6115d3f_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-pkgload:                 1.1.0-r36h0357c0b_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-plyr:                    1.8.6-r36h0357c0b_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-praise:                  1.0.0-r36h6115d3f_1004     conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-prettyunits:             1.1.1-r36h6115d3f_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-processx:                3.4.3-r36hcdcec82_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-ps:                      1.3.4-r36hcdcec82_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-r6:                      2.4.1-r36h6115d3f_1        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-rcolorbrewer:            1.1_2-r36h6115d3f_1003     conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-rcpp:                    1.0.5-r36h0357c0b_0        conda-forge[0m
12:41:23 [32mBIOCONDA INFO[0m (OUT)     r-reshape2:                1.4.4-r36h0357c0b_1        conda-forge[0m
.12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-rlang:                   0.4.7-r36hcdcec82_0        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-rprojroot:               1.3_2-r36h6115d3f_1003     conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-rstudioapi:              0.11-r36h6115d3f_1         conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-scales:                  1.1.1-r36h6115d3f_0        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-stringi:                 1.4.6-r36h604b29c_3        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-stringr:                 1.4.0-r36h6115d3f_2        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-testthat:                2.3.2-r36h0357c0b_1        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-tibble:                  3.0.3-r36hcdcec82_0        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-utf8:                    1.1.4-r36hcdcec82_1003     conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-vctrs:                   0.3.2-r36hcdcec82_0        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-viridislite:             0.3.0-r36h6115d3f_1003     conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-withr:                   2.2.0-r36h6115d3f_1        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     r-zeallot:                 0.1.0-r36h6115d3f_1002     conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     readline:                  8.0-he28a2e2_2             conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     sed:                       4.8-hbfbb72e_0             conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     setuptools:                49.6.0-py38h32f6830_0      conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     sqlite:                    3.33.0-h4cf870e_0          conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     tk:                        8.6.10-hed695b0_0          conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     tktable:                   2.10-h555a92e_3            conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     wheel:                     0.35.1-pyh9f0ad1d_0        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-kbproto:              1.0.7-h14c3975_1002        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libice:               1.0.10-h516909a_0          conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libsm:                1.2.3-h84519dc_1000        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libx11:               1.6.11-h516909a_0          conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libxau:               1.0.9-h14c3975_0           conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libxdmcp:             1.1.3-h516909a_0           conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libxext:              1.3.4-h516909a_0           conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-libxrender:           0.9.10-h516909a_1002       conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-renderproto:          0.11.1-h14c3975_1002       conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-xextproto:            7.3.0-h14c3975_1002        conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xorg-xproto:               7.0.31-h14c3975_1007       conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     xz:                        5.2.5-h516909a_1           conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     zlib:                      1.2.11-h516909a_1007       conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT)     zstd:                      1.4.5-h6597ccf_2           conda-forge[0m
12:42:24 [32mBIOCONDA INFO[0m (OUT) [0m
12:42:25 [32mBIOCONDA INFO[0m (OUT) Preparing transaction: ...working... done[0m
12:42:30 [32mBIOCONDA INFO[0m (OUT) Verifying transaction: ...working... done[0m
.12:42:58 [32mBIOCONDA INFO[0m (OUT) Executing transaction: ...working... done[0m
12:43:15 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
12:43:26 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
12:43:39 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
.12:44:27 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
.12:44:47 [32mBIOCONDA INFO[0m (OUT) [0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) ## Package Plan ##[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) [0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)   environment location: /opt/conda/conda-bld/vsclust_1598359005570/_build_env[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) [0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) [0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) The following NEW packages will be INSTALLED:[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) [0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     _libgcc_mutex:           0.1-conda_forge    conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     _openmp_mutex:           4.5-1_gnu          conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     binutils_impl_linux-64:  2.34-h2122c62_9    conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     binutils_linux-64:       2.34-h47ac705_27   conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     gcc_impl_linux-64:       7.5.0-hda68d29_13  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     gcc_linux-64:            7.5.0-hf34d7eb_27  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     gfortran_impl_linux-64:  7.5.0-h1104b78_16  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     gfortran_linux-64:       7.5.0-ha781d05_27  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     gxx_impl_linux-64:       7.5.0-h64c220c_13  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     gxx_linux-64:            7.5.0-ha781d05_27  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     kernel-headers_linux-64: 2.6.32-h77966d4_13 conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     ld_impl_linux-64:        2.34-hc38a660_9    conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     libgcc-ng:               9.3.0-h24d8f2e_16  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     libgfortran-ng:          7.5.0-hdf63c60_16  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     libgomp:                 9.3.0-h24d8f2e_16  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     libstdcxx-ng:            9.3.0-hdf63c60_16  conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT)     sysroot_linux-64:        2.12-h77966d4_13   conda-forge[0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) [0m
12:44:47 [32mBIOCONDA INFO[0m (OUT) Preparing transaction: ...working... done[0m
12:44:49 [32mBIOCONDA INFO[0m (OUT) Verifying transaction: ...working... done[0m
12:45:03 [32mBIOCONDA INFO[0m (OUT) Executing transaction: ...working... done[0m
12:45:03 [32mBIOCONDA INFO[0m (OUT) Source cache directory is: /opt/conda/conda-bld/src_cache[0m
12:45:03 [32mBIOCONDA INFO[0m (OUT) Downloading source to cache: release-0.86_d94808cc3d.tar.gz[0m
12:45:03 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.source:Source cache directory is: /opt/conda/conda-bld/src_cache[0m
12:45:03 [32mBIOCONDA INFO[0m (OUT) Downloading https://bitbucket.org/veitveit/vsclust/get/release-0.86.tar.gz[0m
12:45:03 [32mBIOCONDA INFO[0m (ERR) INFO conda_build.source:download_to_cache(43): Source cache directory is: /opt/conda/conda-bld/src_cache[0m
12:45:03 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.source:Downloading source to cache: release-0.86_d94808cc3d.tar.gz[0m
12:45:03 [32mBIOCONDA INFO[0m (ERR) INFO conda_build.source:download_to_cache(66): Downloading source to cache: release-0.86_d94808cc3d.tar.gz[0m
12:45:03 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.source:Downloading https://bitbucket.org/veitveit/vsclust/get/release-0.86.tar.gz[0m
12:45:03 [32mBIOCONDA INFO[0m (ERR) INFO conda_build.source:download_to_cache(80): Downloading https://bitbucket.org/veitveit/vsclust/get/release-0.86.tar.gz[0m
12:45:06 [32mBIOCONDA INFO[0m (OUT) Success[0m
12:45:06 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.source:Success[0m
12:45:06 [32mBIOCONDA INFO[0m (ERR) INFO conda_build.source:download_to_cache(91): Success[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) Extracting download[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) source tree in: /opt/conda/conda-bld/vsclust_1598359005570/work[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) export PREFIX=/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) export BUILD_PREFIX=/opt/conda/conda-bld/vsclust_1598359005570/_build_env[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) export SRC_DIR=/opt/conda/conda-bld/vsclust_1598359005570/work[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) INFO: activate-binutils_linux-64.sh made the following environmental changes:[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +ADDR2LINE=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-addr2line[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +AR=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ar[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +AS=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-as[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CXXFILT=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++filt[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +ELFEDIT=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-elfedit[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GPROF=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gprof[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +HOST=x86_64-conda_cos6-linux-gnu[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +LD_GOLD=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld.gold[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +LD=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +NM=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-nm[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +OBJCOPY=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-objcopy[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +OBJDUMP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-objdump[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +RANLIB=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ranlib[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +READELF=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-readelf[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +SIZE=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-size[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +STRINGS=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-strings[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +STRIP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-strip[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gcc_linux-64.sh made the following environmental changes:[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-cc[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CMAKE_PREFIX_PATH=$PREFIX:$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -CONDA_BUILD_SYSROOT=[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CONDA_BUILD_SYSROOT=$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +_CONDA_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata_x86_64_conda_cos6_linux_gnu[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CPPFLAGS=-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CPP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-cpp[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +DEBUG_CFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +DEBUG_CPPFLAGS=-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem $PREFIX/include[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GCC_AR=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-ar[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GCC_NM=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-nm[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GCC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GCC_RANLIB=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-ranlib[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +LDFLAGS=-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gfortran_linux-64.sh made the following environmental changes:[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +DEBUG_FFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +DEBUG_FORTRANFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +F77=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +F90=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +F95=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-f95[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +FC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +FFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +FORTRANFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GFORTRAN=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gxx_linux-64.sh made the following environmental changes:[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CXXFLAGS=-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +DEBUG_CXXFLAGS=-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) INFO: activate-binutils_linux-64.sh made the following environmental changes:[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +ADDR2LINE=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-addr2line[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -ADDR2LINE=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-addr2line[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +AR=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ar[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -AR=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ar[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +AS=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-as[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -AS=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-as[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CXXFILT=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-c++filt[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -CXXFILT=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++filt[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +ELFEDIT=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-elfedit[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -ELFEDIT=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-elfedit[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +GPROF=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gprof[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -GPROF=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gprof[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +LD_GOLD=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ld.gold[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -LD_GOLD=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld.gold[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +LD=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ld[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -LD=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +NM=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-nm[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -NM=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-nm[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +OBJCOPY=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-objcopy[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -OBJCOPY=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-objcopy[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +OBJDUMP=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-objdump[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -OBJDUMP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-objdump[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +RANLIB=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ranlib[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -RANLIB=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ranlib[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +READELF=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-readelf[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -READELF=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-readelf[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +SIZE=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-size[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -SIZE=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-size[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +STRINGS=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-strings[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -STRINGS=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-strings[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +STRIP=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-strip[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -STRIP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-strip[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gcc_linux-64.sh made the following environmental changes:[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +build_alias=x86_64-conda-linux-gnu[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -BUILD=x86_64-conda_cos6-linux-gnu[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +BUILD=x86_64-conda-linux-gnu[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CC_FOR_BUILD=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-cc[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CC=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-cc[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) -CC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-cc[0m
12:45:07 [32mBIOCONDA INFO[0m (OUT) +CMAKE_ARGS=-DCMAKE_LINKER=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ld -DCMAKE_STRIP=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-strip -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH=$PREFIX;$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib[0m
12:45:08 [32mBIOCONDA INFO[0m (ERR) * installing to library ‘/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library’[0m
12:45:08 [32mBIOCONDA INFO[0m (ERR) * installing *source* package ‘e1071FuzzVec’ ...[0m
12:45:08 [32mBIOCONDA INFO[0m (ERR) ** using staged installation[0m
12:45:09 [32mBIOCONDA INFO[0m (ERR) ** libs[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp: In function 'svm_model* svm_load_model(const char*)':[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2788:9: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)    fscanf(fp,"%80s",cmd);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)    ~~~~~~^~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2792:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%80s",cmd);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2817:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%80s",cmd);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2841:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%d",&param.degree);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2843:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%lf",&param.gamma);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2845:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%lf",&param.coef0);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2847:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%d",&model->nr_class);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2849:10: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     fscanf(fp,"%d",&model->l);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)     ~~~~~~^~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2855:11: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      fscanf(fp,"%lf",&model->rho[i]);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2862:11: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      fscanf(fp,"%d",&model->label[i]);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2869:11: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      fscanf(fp,"%lf",&model->probA[i]);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2876:11: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      fscanf(fp,"%lf",&model->probB[i]);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR) svm.cpp:2883:11: warning: ignoring return value of 'int fscanf(FILE*, const char*, ...)', declared with attribute warn_unused_result [-Wunused-result][0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      fscanf(fp,"%d",&model->nSV[i]);[0m
12:45:10 [32mBIOCONDA INFO[0m (ERR)      ~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~[0m
12:45:11 [32mBIOCONDA INFO[0m (ERR) installing to /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/00LOCK-e1071FuzzVec_Installation/00new/e1071FuzzVec/libs[0m
12:45:11 [32mBIOCONDA INFO[0m (ERR) ** R[0m
12:45:11 [32mBIOCONDA INFO[0m (ERR) ** inst[0m
12:45:11 [32mBIOCONDA INFO[0m (ERR) ** byte-compile and prepare package for lazy loading[0m
12:45:13 [32mBIOCONDA INFO[0m (ERR) ** help[0m
12:45:13 [32mBIOCONDA INFO[0m (ERR) *** installing help indices[0m
12:45:13 [32mBIOCONDA INFO[0m (ERR) ** building package indices[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) ** installing vignettes[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) ** testing if installed package can be loaded from temporary location[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) ** checking absolute paths in shared objects and dynamic libraries[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) ** testing if installed package can be loaded from final location[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) ** testing if installed package keeps a record of temporary installation path[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) * creating tarball[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) packaged installation of ‘e1071FuzzVec’ as ‘e1071FuzzVec_1.6-7_R_x86_64-conda_cos6-linux-gnu.tar.gz’[0m
12:45:14 [32mBIOCONDA INFO[0m (ERR) * DONE (e1071FuzzVec)[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +CMAKE_PREFIX_PATH=$PREFIX:$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -CMAKE_PREFIX_PATH=$PREFIX:$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr[0m
12:45:15 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.build:Packaging vsclust[0m
12:45:15 [32mBIOCONDA INFO[0m (ERR) INFO conda_build.build:build(2074): Packaging vsclust[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +CONDA_BUILD_SYSROOT=$BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -CONDA_BUILD_SYSROOT=$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +CPP=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-cpp[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -CPP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-cpp[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +GCC_AR=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gcc-ar[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -GCC_AR=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-ar[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +GCC_NM=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gcc-nm[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -GCC_NM=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-nm[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +GCC=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gcc[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -GCC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +GCC_RANLIB=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gcc-ranlib[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -GCC_RANLIB=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-ranlib[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +host_alias=x86_64-conda-linux-gnu[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -HOST=x86_64-conda_cos6-linux-gnu[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +HOST=x86_64-conda-linux-gnu[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gfortran_linux-64.sh made the following environmental changes:[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +DEBUG_FFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -DEBUG_FFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +DEBUG_FORTRANFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -DEBUG_FORTRANFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +F95=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-f95[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -F95=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-f95[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +GFORTRAN=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gfortran[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -GFORTRAN=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gxx_linux-64.sh made the following environmental changes:[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +CXX_FOR_BUILD=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-c++[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +CXX=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-c++[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -CXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) +GXX=$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-g++[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) -GXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) files ‘DESCRIPTION’, ‘NAMESPACE’, ‘R/cmeans.R’, ‘man/cmeans.Rd’, ‘src/cmeans.c’ have the wrong MD5 checksums[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking for x86_64-conda-linux-gnu-g++... x86_64-conda_cos6-linux-gnu-c++ -std=gnu++11[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking for C++ compiler default output file name... a.out[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking whether the C++ compiler works... yes[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking whether we are cross compiling... no[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking for suffix of executables...[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking for suffix of object files... o[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking whether we are using the GNU C++ compiler... yes[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) checking whether x86_64-conda_cos6-linux-gnu-c++ -std=gnu++11 accepts -g... yes[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) x86_64-conda_cos6-linux-gnu-cc -I"$PREFIX/lib/R/include" -DNDEBUG   -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include -I$PREFIX/include -Wl,-rpath-link,$PREFIX/lib  -fpic  -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1595324536449/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix  -c Rsvm.c -o Rsvm.o[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) x86_64-conda_cos6-linux-gnu-cc -I"$PREFIX/lib/R/include" -DNDEBUG   -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include -I$PREFIX/include -Wl,-rpath-link,$PREFIX/lib  -fpic  -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1595324536449/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix  -c cmeans.c -o cmeans.o[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) x86_64-conda_cos6-linux-gnu-cc -I"$PREFIX/lib/R/include" -DNDEBUG   -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include -I$PREFIX/include -Wl,-rpath-link,$PREFIX/lib  -fpic  -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1595324536449/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix  -c cshell.c -o cshell.o[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) x86_64-conda_cos6-linux-gnu-cc -I"$PREFIX/lib/R/include" -DNDEBUG   -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include -I$PREFIX/include -Wl,-rpath-link,$PREFIX/lib  -fpic  -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1595324536449/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix  -c floyd.c -o floyd.o[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) x86_64-conda_cos6-linux-gnu-c++ -std=gnu++11 -I"$PREFIX/lib/R/include" -DNDEBUG   -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include -I$PREFIX/include -Wl,-rpath-link,$PREFIX/lib  -fpic  -fvisibility-inlines-hidden  -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1595324536449/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix  -c svm.cpp -o svm.o[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) x86_64-conda_cos6-linux-gnu-c++ -std=gnu++11 -shared -L$PREFIX/lib/R/lib -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -o e1071FuzzVec.so Rsvm.o cmeans.o cshell.o floyd.o svm.o -L$PREFIX/lib/R/lib -lR[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) [0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) Resource usage statistics from building vsclust:[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT)    Process count: 7[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT)    CPU time: Sys=0:00:01.7, User=0:00:03.5[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT)    Memory: 137.9M[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT)    Disk usage: 13.0K[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT)    Time elapsed: 0:00:08.2[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) [0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) Packaging vsclust[0m
12:45:15 [32mBIOCONDA INFO[0m (OUT) Packaging vsclust-0.86-r36h4333106_0[0m
12:45:15 [32mBIOCONDA INFO[0m (ERR) INFO:conda_build.build:Packaging vsclust-0.86-r36h4333106_0[0m
12:45:15 [32mBIOCONDA INFO[0m (ERR) INFO conda_build.build:bundle_conda(1388): Packaging vsclust-0.86-r36h4333106_0[0m
12:45:17 [32mBIOCONDA INFO[0m (ERR) patchelf: wrong ELF type[0m
12:45:17 [32mBIOCONDA INFO[0m (ERR) patchelf: wrong ELF type[0m
12:45:17 [32mBIOCONDA INFO[0m (ERR) patchelf: wrong ELF type[0m
12:45:17 [32mBIOCONDA INFO[0m (ERR) patchelf: wrong ELF type[0m
12:45:18 [32mBIOCONDA INFO[0m (ERR) patchelf: wrong ELF type[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) number of files: 136[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: `patchelf --print-rpath` failed for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/Rsvm.o, will proceed with LIEF (was None)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: `patchelf --print-rpath` failed for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/floyd.o, will proceed with LIEF (was None)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: `patchelf --print-rpath` failed for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/svm.o, will proceed with LIEF (was None)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: get_rpaths_raw()=['/opt/conda/conda-bld/vsclust_1598359005570/_build_env/lib:/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib'] and patchelf=[['/opt/conda/conda-bld/vsclust_1598359005570/_build_env/lib', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib']] disagree for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so ::[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) Warning: rpath /opt/conda/conda-bld/vsclust_1598359005570/_build_env/lib is outside prefix /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place (removing it)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: `patchelf --print-rpath` failed for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/cshell.o, will proceed with LIEF (was None)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: get_rpaths_raw()=['/opt/conda/conda-bld/vsclust_1598359005570/_build_env/lib:/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib'] and patchelf=[['/opt/conda/conda-bld/vsclust_1598359005570/_build_env/lib', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib']] disagree for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/libs/e1071FuzzVec.so ::[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) Warning: rpath /opt/conda/conda-bld/vsclust_1598359005570/_build_env/lib is outside prefix /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place (removing it)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING :: `patchelf --print-rpath` failed for /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/cmeans.o, will proceed with LIEF (was None)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) WARNING: Disagreement in get_linkages(filename=/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so, resolve_filenames=True, recurse=False, sysroot=/opt/conda/conda-bld/vsclust_1598359005570/_build_env/x86_64-conda-linux-gnu/sysroot/, envroot=/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place, arch=native):[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT)  lief: {'/opt/conda/conda-bld/vsclust_1598359005570/_build_env/x86_64-conda-linux-gnu/sysroot/lib64/libm.so.6', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/../../../../libgcc_s.so.1', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/../../../../libstdc++.so.6', '/opt/conda/conda-bld/vsclust_1598359005570/_build_env/x86_64-conda-linux-gnu/sysroot/lib64/libc.so.6', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/../../../lib/libR.so'}[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT) pyldd: {'/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/../../../../libgcc_s.so.1', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/../../../../libstdc++.so.6', '/opt/conda/conda-bld/vsclust_1598359005570/_build_env/x86_64-conda-linux-gnu/sysroot/lib/libc.so.6', '/opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place/lib/R/library/e1071FuzzVec/src/../../../lib/libR.so', '/opt/conda/conda-bld/vsclust_1598359005570/_build_env/x86_64-conda-linux-gnu/sysroot/lib/libm.so.6'}[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT)   (using lief)[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so): Needed DSO x86_64-conda-linux-gnu/sysroot/lib64/libm.so.6 found in CDT/compiler package conda-forge::sysroot_linux-64-2.12-h77966d4_13[0m
12:45:21 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so): Needed DSO lib/libgcc_s.so.1 found in conda-forge::libgcc-ng-9.3.0-h24d8f2e_16[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so): Needed DSO lib/libstdc++.so.6 found in conda-forge::libstdcxx-ng-9.3.0-hdf63c60_16[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so): Needed DSO x86_64-conda-linux-gnu/sysroot/lib64/libc.so.6 found in CDT/compiler package conda-forge::sysroot_linux-64-2.12-h77966d4_13[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/src/e1071FuzzVec.so): Needed DSO lib/R/lib/libR.so found in conda-forge::r-base-3.6.3-he766273_3[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/libs/e1071FuzzVec.so): Needed DSO x86_64-conda-linux-gnu/sysroot/lib64/libm.so.6 found in CDT/compiler package conda-forge::sysroot_linux-64-2.12-h77966d4_13[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/libs/e1071FuzzVec.so): Needed DSO lib/libgcc_s.so.1 found in conda-forge::libgcc-ng-9.3.0-h24d8f2e_16[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/libs/e1071FuzzVec.so): Needed DSO lib/libstdc++.so.6 found in conda-forge::libstdcxx-ng-9.3.0-hdf63c60_16[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/libs/e1071FuzzVec.so): Needed DSO x86_64-conda-linux-gnu/sysroot/lib64/libc.so.6 found in CDT/compiler package conda-forge::sysroot_linux-64-2.12-h77966d4_13[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust,lib/R/library/e1071FuzzVec/libs/e1071FuzzVec.so): Needed DSO lib/R/lib/libR.so found in conda-forge::r-base-3.6.3-he766273_3[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust): plugin library package bioconda::bioconductor-limma-3.42.0-r36h516909a_0 in requirements/run but it is not used (i.e. it is overdepending or perhaps statically linked? If that is what you want then add it to `build/ignore_run_exports`)[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) WARNING (vsclust): dso library package conda-forge::libgfortran-ng-7.5.0-hdf63c60_16 in requirements/run but it is not used (i.e. it is overdepending or perhaps statically linked? If that is what you want then add it to `build/ignore_run_exports`)[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)    INFO (vsclust): plugin library package conda-forge::r-matrixstats-0.56.0-r36hcdcec82_1 in requirements/run but it is not used (i.e. it is overdepending or perhaps statically linked? If that is what you want then add it to `build/ignore_run_exports`)[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) Fixing permissions[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) Packaged license file/s.[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) INFO :: Time taken to mark (prefix)[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT)         0 replacements in 0 files was 0.07 seconds[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) Files containing CONDA_PREFIX[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) -----------------------------[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) /opt/conda/conda-bld/vsclust_1598359005570/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_place :: text :: lib/R/library/e1071FuzzVec/config.log[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) lib/R/library/e1071FuzzVec/config.log (text): Patching[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) Package verification results:[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) -----------------------------[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) TEST START: /opt/conda/conda-bld/linux-64/vsclust-0.86-r36h4333106_0.tar.bz2[0m
12:45:30 [32mBIOCONDA INFO[0m (OUT) Renaming work directory,  /opt/conda/conda-bld/vsclust_1598359005570/work  to  /opt/conda/conda-bld/vsclust_1598359005570/work_moved_vsclust-0.86-r36h4333106_0_linux-64[0m
.12:45:45 [32mBIOCONDA INFO[0m (OUT) Collecting package metadata (repodata.json): ...working... done[0m
12:46:30 [32mBIOCONDA INFO[0m (OUT) Solving environment: ...working... done[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) [0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) ## Package Plan ##[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) [0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)   environment location: /opt/conda/conda-bld/vsclust_1598359005570/_test_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) [0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) [0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) The following NEW packages will be INSTALLED:[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT) [0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     _libgcc_mutex:                 0.1-conda_forge            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     _openmp_mutex:                 4.5-1_gnu                  conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     _r-mutex:                      1.0.1-anacondar_1          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     binutils_impl_linux-64:        2.34-h53a641e_7            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     binutils_linux-64:             2.34-hc952b39_20           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-annotate:         1.64.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-annotationdbi:    1.48.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-annotationforge:  1.28.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-biobase:          2.46.0-r36h516909a_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-biocgenerics:     0.32.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-biocparallel:     1.20.0-r36he1b5a44_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-category:         2.52.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-clusterprofiler:  3.14.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-do.db:            2.9-r36_7                  bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-dose:             3.12.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-dyndoc:           1.64.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-enrichplot:       1.6.0-r36_0                bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-fgsea:            1.12.0-r36he1b5a44_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-genefilter:       1.68.0-r36hc99cbb1_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-go.db:            3.10.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-gosemsim:         2.12.0-r36he1b5a44_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-gostats:          2.52.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-graph:            1.64.0-r36h516909a_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-gseabase:         1.48.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-iranges:          2.20.0-r36h516909a_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-limma:            3.42.0-r36h516909a_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-mfuzz:            2.46.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-qvalue:           2.18.0-r36_1               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-rbgl:             1.62.1-r36he1b5a44_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-rdavidwebservice: 1.24.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-rgraphviz:        2.30.0-r36he1b5a44_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-s4vectors:        0.24.0-r36h516909a_0       bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-tkwidgets:        1.64.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bioconductor-widgettools:      1.64.0-r36_0               bioconda[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bwidget:                       1.9.14-0                   conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     bzip2:                         1.0.8-h516909a_3           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     c-ares:                        1.16.1-h516909a_3          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     ca-certificates:               2020.6.20-hecda079_0       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     cairo:                         1.16.0-h3fc0475_1005       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     certifi:                       2020.6.20-py38h32f6830_0   conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     curl:                          7.71.1-he644dc0_5          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     fontconfig:                    2.13.1-h1056068_1002       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     freetype:                      2.10.2-he06d7ca_0          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     fribidi:                       1.0.10-h516909a_0          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gcc_impl_linux-64:             7.5.0-hd420e75_6           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gcc_linux-64:                  7.5.0-h09487f9_20          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gettext:                       0.19.8.1-hc5be6a0_1002     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gfortran_impl_linux-64:        7.5.0-hdf63c60_6           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gfortran_linux-64:             7.5.0-h09487f9_20          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     glib:                          2.65.0-h6f030ca_0          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gmp:                           6.2.0-he1b5a44_2           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     graphite2:                     1.3.13-he1b5a44_1001       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gsl:                           2.6-h294904e_0             conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gxx_impl_linux-64:             7.5.0-hdf63c60_6           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     gxx_linux-64:                  7.5.0-h09487f9_20          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     harfbuzz:                      2.7.1-hee91db6_0           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     icu:                           67.1-he1b5a44_0            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     jpeg:                          9d-h516909a_0              conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     krb5:                          1.17.1-hfafb76e_2          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     ld_impl_linux-64:              2.34-h53a641e_7            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libblas:                       3.8.0-17_openblas          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libcblas:                      3.8.0-17_openblas          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libcurl:                       7.71.1-hcdd3856_5          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libedit:                       3.1.20191231-he28a2e2_2    conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libev:                         4.33-h516909a_0            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libffi:                        3.2.1-he1b5a44_1007        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libgcc-ng:                     9.3.0-h24d8f2e_16          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libgfortran-ng:                7.5.0-hdf63c60_16          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libgomp:                       9.3.0-h24d8f2e_16          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libiconv:                      1.16-h516909a_0            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     liblapack:                     3.8.0-17_openblas          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libnghttp2:                    1.41.0-hab1572f_1          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libopenblas:                   0.3.10-pthreads_hb3c22a3_4 conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libpng:                        1.6.37-hed695b0_2          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libssh2:                       1.9.0-hab1572f_5           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libstdcxx-ng:                  9.3.0-hdf63c60_16          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libtiff:                       4.1.0-hc7e4089_6           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libuuid:                       2.32.1-h14c3975_1000       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libwebp-base:                  1.1.0-h516909a_3           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libxcb:                        1.13-h14c3975_1002         conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     libxml2:                       2.9.10-h68273f3_2          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     lz4-c:                         1.9.2-he1b5a44_3           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     make:                          4.3-h516909a_0             conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     ncurses:                       6.2-he1b5a44_1             conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     openjdk:                       8.0.192-h516909a_1005      conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     openssl:                       1.1.1g-h516909a_1          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     pango:                         1.42.4-h7062337_4          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     pcre:                          8.44-he1b5a44_0            conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     pip:                           20.2.2-py_0                conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     pixman:                        0.38.0-h516909a_1003       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     pthread-stubs:                 0.4-h14c3975_1001          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     python:                        3.8.5-h1103e12_5_cpython   conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     python_abi:                    3.8-1_cp38                 conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-askpass:                     1.1-r36hcdcec82_2          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-assertthat:                  0.2.1-r36h6115d3f_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-backports:                   1.1.9-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-base:                        3.6.3-he766273_3           conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-base64enc:                   0.1_3-r36hcdcec82_1004     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-bh:                          1.72.0_3-r36h6115d3f_1     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-biocmanager:                 1.30.10-r36h6115d3f_1      conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-bit:                         4.0.4-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-bit64:                       4.0.2-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-bitops:                      1.0_6-r36hcdcec82_1004     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-blob:                        1.2.1-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-callr:                       3.4.3-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-cellranger:                  1.1.0-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-class:                       7.3_17-r36hcdcec82_1       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-cli:                         2.0.2-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-colorspace:                  1.4_1-r36hcdcec82_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-commonmark:                  1.7-r36hcdcec82_1002       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-cowplot:                     1.0.0-r36h6115d3f_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-crayon:                      1.3.4-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-curl:                        4.3-r36hcdcec82_1          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-data.table:                  1.12.8-r36hcdcec82_1       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-dbi:                         1.1.0-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-desc:                        1.2.0-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-digest:                      0.6.25-r36h0357c0b_2       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-dplyr:                       1.0.2-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-e1071:                       1.7_3-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ellipsis:                    0.3.1-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-europepmc:                   0.4-r36h6115d3f_0          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-evaluate:                    0.14-r36h6115d3f_2         conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-fansi:                       0.4.1-r36hcdcec82_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-farver:                      2.0.3-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-fastmap:                     1.0.1-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-fastmatch:                   1.1_0-r36hcdcec82_1005     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-formatr:                     1.7-r36h6115d3f_2          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-futile.logger:               1.4.3-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-futile.options:              1.0.1-r36h6115d3f_1002     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-generics:                    0.0.2-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ggforce:                     0.3.2-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ggplot2:                     3.3.2-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ggplotify:                   0.0.5-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ggraph:                      2.0.3-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ggrepel:                     0.8.2-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ggridges:                    0.5.2-r36h6115d3f_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-glue:                        1.4.1-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-graphlayouts:                0.7.0-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-gridextra:                   2.3-r36h6115d3f_1003       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-gridgraphics:                0.5_0-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-gtable:                      0.3.0-r36h6115d3f_3        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-hms:                         0.5.3-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-htmltools:                   0.5.0-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-httpuv:                      1.5.4-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-httr:                        1.4.2-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-igraph:                      1.2.5-r36hd626d4e_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-isoband:                     0.2.2-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-jsonlite:                    1.7.0-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-labeling:                    0.3-r36h6115d3f_1003       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-lambda.r:                    1.2.4-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-later:                       1.1.0.1-r36h0357c0b_0      conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-lattice:                     0.20_41-r36hcdcec82_2      conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-lifecycle:                   0.2.0-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-magrittr:                    1.5-r36h6115d3f_1003       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-mass:                        7.3_52-r36hcdcec82_0       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-matrix:                      1.2_18-r36h7fa42b6_3       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-matrixstats:                 0.56.0-r36hcdcec82_1       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-memoise:                     1.1.0-r36h6115d3f_1004     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-mgcv:                        1.8_32-r36h7fa42b6_0       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-mime:                        0.9-r36hcdcec82_1          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-munsell:                     0.5.0-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-nlme:                        3.1_149-r36h9bbef5b_0      conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-openssl:                     1.4.2-r36he5c4762_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-pillar:                      1.4.6-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-pkgbuild:                    1.1.0-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-pkgconfig:                   2.0.3-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-pkgload:                     1.1.0-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-plogr:                       0.2.0-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-plyr:                        1.8.6-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-polyclip:                    1.10_0-r36h0357c0b_2       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-praise:                      1.0.0-r36h6115d3f_1004     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-prettyunits:                 1.1.1-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-processx:                    3.4.3-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-progress:                    1.2.2-r36h6115d3f_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-promises:                    1.1.1-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-ps:                          1.3.4-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-purrr:                       0.3.4-r36hcdcec82_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-r6:                          2.4.1-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rcolorbrewer:                1.1_2-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rcpp:                        1.0.5-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rcpparmadillo:               0.9.900.2.0-r36h51c796c_0  conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rcppeigen:                   0.3.3.7.0-r36h51c796c_2    conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rcurl:                       1.98_1.2-r36hcdcec82_1     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-readxl:                      1.3.1-r36hde08347_4        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rematch:                     1.0.1-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-reshape2:                    1.4.4-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rjava:                       0.9_13-r36hcdcec82_3       conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rlang:                       0.4.7-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rprojroot:                   1.3_2-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rsqlite:                     2.2.0-r36h0357c0b_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rstudioapi:                  0.11-r36h6115d3f_1         conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-rvcheck:                     0.1.8-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-scales:                      1.1.1-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-shiny:                       1.5.0-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-shinyjs:                     1.1-r36h6115d3f_1          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-shinythemes:                 1.1.2-r36h6115d3f_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-snow:                        0.4_3-r36h6115d3f_1002     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-sourcetools:                 0.1.7-r36he1b5a44_1002     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-stringi:                     1.4.6-r36h604b29c_3        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-stringr:                     1.4.0-r36h6115d3f_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-survival:                    3.2_3-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-sys:                         3.4-r36hcdcec82_0          conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-testthat:                    2.3.2-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-tibble:                      3.0.3-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-tidygraph:                   1.2.0-r36h0357c0b_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-tidyr:                       1.1.1-r36h0357c0b_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-tidyselect:                  1.1.0-r36h6115d3f_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-triebeard:                   0.3.0-r36he1b5a44_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-tweenr:                      1.0.1-r36h0357c0b_1002     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-urltools:                    1.7.3-r36h0357c0b_2        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-utf8:                        1.1.4-r36hcdcec82_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-vctrs:                       0.3.2-r36hcdcec82_0        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-viridis:                     0.5.1-r36h6115d3f_1004     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-viridislite:                 0.3.0-r36h6115d3f_1003     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-withr:                       2.2.0-r36h6115d3f_1        conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-xml:                         3.99_0.3-r36hcdcec82_1     conda-forge[0m
12:46:32 [32mBIOCONDA INFO[0m (OUT)     r-xml2:                        1.3.2-r36h0357c0b_1        conda-forge[0m
.12:47:27 [32mBIOCONDA INFO[0m (OUT)     r-xtable:                      1.8_4-r36h6115d3f_3        conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     r-yaml:                        2.2.1-r36hcdcec82_1        conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     r-zeallot:                     0.1.0-r36h6115d3f_1002     conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     readline:                      8.0-he28a2e2_2             conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     sed:                           4.8-hbfbb72e_0             conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     setuptools:                    49.6.0-py38h32f6830_0      conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     sqlite:                        3.33.0-h4cf870e_0          conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     tk:                            8.6.10-hed695b0_0          conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     tktable:                       2.10-h555a92e_3            conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     vsclust:                       0.86-r36h4333106_0         local[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     wheel:                         0.35.1-pyh9f0ad1d_0        conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-kbproto:                  1.0.7-h14c3975_1002        conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libice:                   1.0.10-h516909a_0          conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libsm:                    1.2.3-h84519dc_1000        conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libx11:                   1.6.11-h516909a_0          conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libxau:                   1.0.9-h14c3975_0           conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libxdmcp:                 1.1.3-h516909a_0           conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libxext:                  1.3.4-h516909a_0           conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-libxrender:               0.9.10-h516909a_1002       conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-renderproto:              0.11.1-h14c3975_1002       conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-xextproto:                7.3.0-h14c3975_1002        conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xorg-xproto:                   7.0.31-h14c3975_1007       conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     xz:                            5.2.5-h516909a_1           conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     zlib:                          1.2.11-h516909a_1007       conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT)     zstd:                          1.4.5-h6597ccf_2           conda-forge[0m
12:47:27 [32mBIOCONDA INFO[0m (OUT) [0m
12:47:30 [32mBIOCONDA INFO[0m (OUT) Preparing transaction: ...working... done[0m
12:47:38 [32mBIOCONDA INFO[0m (OUT) Verifying transaction: ...working... done[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) /tmp/tmpz50e5f83/vsclust-0.86-r36h4333106_0.tar.bz2: C1125 Found unallowed file in tar archive: lib/R/library/e1071FuzzVec/R/cmeans.R~[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) ClobberWarning: This transaction has incompatible packages due to a shared path.[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR)   packages: conda-forge/linux-64::libgomp-9.3.0-h24d8f2e_16, conda-forge/linux-64::gcc_impl_linux-64-7.5.0-hd420e75_6[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR)   path: 'lib/libgomp.so'[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) ClobberWarning: Conda was asked to clobber an existing path.[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR)   source path: /opt/conda/pkgs/gcc_impl_linux-64-7.5.0-hd420e75_6/lib/libgomp.so[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR)   target path: /opt/conda/conda-bld/vsclust_1598359005570/_test_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_/lib/libgomp.so[0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
12:47:38 [32mBIOCONDA INFO[0m (ERR) [0m
.12:48:17 [32mBIOCONDA INFO[0m (OUT) Executing transaction: ...working... done[0m
12:48:20 [32mBIOCONDA INFO[0m (ERR) + cp /opt/conda/conda-bld/vsclust_1598359005570/_test_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_/bin/ProtExample.csv .[0m
12:48:20 [32mBIOCONDA INFO[0m (ERR) cp: cannot stat `/opt/conda/conda-bld/vsclust_1598359005570/_test_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_/bin/ProtExample.csv': No such file or directory[0m
12:48:22 [32mBIOCONDA INFO[0m (ERR) Tests failed for vsclust-0.86-r36h4333106_0.tar.bz2 - moving package to /opt/conda/conda-bld/broken[0m
12:48:22 [32mBIOCONDA INFO[0m (ERR) WARNING:conda_build.build:Tests failed for vsclust-0.86-r36h4333106_0.tar.bz2 - moving package to /opt/conda/conda-bld/broken[0m
12:48:22 [32mBIOCONDA INFO[0m (ERR) WARNING conda_build.build:tests_failed(2751): Tests failed for vsclust-0.86-r36h4333106_0.tar.bz2 - moving package to /opt/conda/conda-bld/broken[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) export PREFIX=/opt/conda/conda-bld/vsclust_1598359005570/_test_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) export SRC_DIR=/opt/conda/conda-bld/vsclust_1598359005570/test_tmp[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) INFO: activate-binutils_linux-64.sh made the following environmental changes:[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +ADDR2LINE=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-addr2line[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +AR=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ar[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +AS=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-as[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CXXFILT=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++filt[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +ELFEDIT=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-elfedit[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GPROF=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gprof[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +HOST=x86_64-conda_cos6-linux-gnu[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +LD_GOLD=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld.gold[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +LD=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ld[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +NM=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-nm[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +OBJCOPY=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-objcopy[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +OBJDUMP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-objdump[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +RANLIB=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-ranlib[0m
12:48:22 [32mBIOCONDA INFO[0m (ERR) TESTS FAILED: vsclust-0.86-r36h4333106_0.tar.bz2[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +READELF=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-readelf[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +SIZE=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-size[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +STRINGS=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-strings[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +STRIP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-strip[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gcc_linux-64.sh made the following environmental changes:[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-cc[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CMAKE_PREFIX_PATH=$PREFIX:$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CONDA_BUILD_SYSROOT=$PREFIX/x86_64-conda_cos6-linux-gnu/sysroot[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +_CONDA_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata_x86_64_conda_cos6_linux_gnu[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CPPFLAGS=-DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem $PREFIX/include[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CPP=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-cpp[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +DEBUG_CFLAGS=-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +DEBUG_CPPFLAGS=-D_DEBUG -D_FORTIFY_SOURCE=2 -Og -isystem $PREFIX/include[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GCC_AR=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-ar[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GCC_NM=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-nm[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GCC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GCC_RANLIB=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gcc-ranlib[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +LDFLAGS=-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gfortran_linux-64.sh made the following environmental changes:[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +DEBUG_FFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +DEBUG_FORTRANFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix -fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +F77=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +F90=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +F95=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-f95[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +FC=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +FFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +FORTRANFLAGS=-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GFORTRAN=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) INFO: activate-gxx_linux-64.sh made the following environmental changes:[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CXXFLAGS=-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +CXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-c++[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +DEBUG_CXXFLAGS=-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe -isystem $PREFIX/include -fdebug-prefix-map=$SRC_DIR=/usr/local/src/conda/vsclust-0.86 -fdebug-prefix-map=$PREFIX=/usr/local/src/conda-prefix[0m
12:48:22 [32mBIOCONDA INFO[0m (OUT) +GXX=$PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++[0m
12:48:24 [31mBIOCONDA ERROR[0m COMMAND FAILED (exited with 1): /opt/conda/bin/conda build --override-channels --no-anaconda-upload -c conda-forge -c bioconda -c defaults -e /opt/conda/conda_build_config.yaml -e /opt/conda/lib/python3.7/site-packages/bioconda_utils/bioconda_utils-conda_build_config.yaml recipes/vsclust/meta.yaml[0m

12:48:24 [31mBIOCONDA ERROR[0m BUILD FAILED recipes/vsclust[0m
12:48:24 [32mBIOCONDA INFO[0m (COMMAND) conda build purge[0m
12:48:26 [32mBIOCONDA INFO[0m CLEANING UP PACKAGE CACHE (free space: 0MB).[0m
12:48:26 [32mBIOCONDA INFO[0m (COMMAND) conda clean --all[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Cache location: /opt/conda/pkgs[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Will remove the following tarballs:[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) [0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) /opt/conda/pkgs[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) ---------------[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-shinyjs-1.1-r36h6115d3f_1.tar.bz2          1.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-askpass-1.1-r36hcdcec82_2.tar.bz2           28 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gxx_impl_linux-64-7.5.0-hdf63c60_6.tar.bz2    19.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-annotationforge-1.28.0-r36_0.tar.bz2     4.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rprojroot-1.3_2-r36h6115d3f_1003.tar.bz2      94 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-gseabase-1.48.0-r36_0.tar.bz2    1004 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-biocmanager-1.30.10-r36h6115d3f_1.tar.bz2     104 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-urltools-1.7.3-r36h0357c0b_2.tar.bz2       308 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-renderproto-0.11.1-h14c3975_1002.tar.bz2       8 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libsm-1.2.3-h84519dc_1000.tar.bz2        25 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-progress-1.2.2-r36h6115d3f_2.tar.bz2        90 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-viridis-0.5.1-r36h6115d3f_1004.tar.bz2     1.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-purrr-0.3.4-r36hcdcec82_1.tar.bz2          411 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-class-7.3_17-r36hcdcec82_1.tar.bz2         107 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-biobase-2.46.0-r36h516909a_0.tar.bz2     2.3 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libgcc-ng-9.3.0-h24d8f2e_16.tar.bz2          7.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-kbproto-1.0.7-h14c3975_1002.tar.bz2      26 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-hms-0.5.3-r36h6115d3f_1.tar.bz2            122 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-enrichplot-1.6.0-r36_0.tar.bz2     176 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-qvalue-2.18.0-r36_1.tar.bz2     2.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-later-1.1.0.1-r36h0357c0b_0.tar.bz2        156 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gcc_linux-64-7.5.0-h09487f9_20.tar.bz2        22 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-tweenr-1.0.1-r36h0357c0b_1002.tar.bz2      323 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-graphlayouts-0.7.0-r36h0357c0b_1.tar.bz2     2.4 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) c-ares-1.16.1-h516909a_3.tar.bz2             107 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-futile.logger-1.4.3-r36h6115d3f_1003.tar.bz2     108 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libpng-1.6.37-hed695b0_2.tar.bz2             359 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-annotationdbi-1.48.0-r36_0.tar.bz2     4.9 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-bh-1.72.0_3-r36h6115d3f_1.tar.bz2         10.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-tidygraph-1.2.0-r36h0357c0b_0.tar.bz2      529 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-tidyselect-1.1.0-r36h6115d3f_0.tar.bz2     205 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gfortran_impl_linux-64-7.5.0-hdf63c60_6.tar.bz2     9.4 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-rgraphviz-2.30.0-r36he1b5a44_0.tar.bz2     1.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-tidyr-1.1.1-r36h0357c0b_1.tar.bz2          801 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) pango-1.42.4-h7062337_4.tar.bz2              521 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libxdmcp-1.1.3-h516909a_0.tar.bz2        18 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rcpp-1.0.5-r36h0357c0b_0.tar.bz2           2.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ggforce-0.3.2-r36h0357c0b_0.tar.bz2        1.9 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-dyndoc-1.64.0-r36_0.tar.bz2     182 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-biocgenerics-0.32.0-r36_0.tar.bz2     691 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-sourcetools-0.1.7-r36he1b5a44_1002.tar.bz2      52 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-yaml-2.2.1-r36hcdcec82_1.tar.bz2           117 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-shinythemes-1.1.2-r36h6115d3f_2.tar.bz2     698 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libwebp-base-1.1.0-h516909a_3.tar.bz2        845 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-callr-3.4.3-r36h6115d3f_1.tar.bz2          392 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-gostats-2.52.0-r36_0.tar.bz2     2.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-xproto-7.0.31-h14c3975_1007.tar.bz2      72 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-s4vectors-0.24.0-r36h516909a_0.tar.bz2     2.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-dbi-1.1.0-r36h6115d3f_1.tar.bz2            625 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ggraph-2.0.3-r36h0357c0b_0.tar.bz2         3.9 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-xml2-1.3.2-r36h0357c0b_1.tar.bz2           249 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-gridgraphics-0.5_0-r36h6115d3f_1.tar.bz2     262 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rcpparmadillo-0.9.900.2.0-r36h51c796c_0.tar.bz2     1.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-rdavidwebservice-1.24.0-r36_0.tar.bz2    21.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ggridges-0.5.2-r36h6115d3f_2.tar.bz2       2.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) binutils_linux-64-2.34-hc952b39_20.tar.bz2      21 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-triebeard-0.3.0-r36he1b5a44_1003.tar.bz2     179 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-base-3.6.3-he766273_3.tar.bz2             23.3 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gcc_impl_linux-64-7.5.0-hd420e75_6.tar.bz2    70.6 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-cli-2.0.2-r36h6115d3f_1.tar.bz2            395 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-snow-0.4_3-r36h6115d3f_1002.tar.bz2        124 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-pkgbuild-1.1.0-r36h6115d3f_0.tar.bz2       155 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) freetype-2.10.2-he06d7ca_0.tar.bz2           905 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bzip2-1.0.8-h516909a_3.tar.bz2               398 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-fgsea-1.12.0-r36he1b5a44_0.tar.bz2    1002 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-vctrs-0.3.2-r36hcdcec82_0.tar.bz2          1.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) python-3.8.5-h1103e12_5_cpython.tar.bz2     21.9 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) fontconfig-2.13.1-h1056068_1002.tar.bz2      365 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) harfbuzz-2.7.1-hee91db6_0.tar.bz2            1.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ggrepel-0.8.2-r36h0357c0b_1.tar.bz2        662 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libxcb-1.13-h14c3975_1002.tar.bz2            396 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ggplot2-3.3.2-r36h6115d3f_0.tar.bz2        3.9 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-isoband-0.2.2-r36h0357c0b_0.tar.bz2        2.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-mime-0.9-r36hcdcec82_1.tar.bz2              52 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gxx_linux-64-7.5.0-ha781d05_27.tar.bz2        22 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ps-1.3.4-r36hcdcec82_0.tar.bz2             234 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-go.db-3.10.0-r36_0.tar.bz2        7 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gfortran_linux-64-7.5.0-ha781d05_27.tar.bz2      22 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-commonmark-1.7-r36hcdcec82_1002.tar.bz2     152 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-labeling-0.3-r36h6115d3f_1003.tar.bz2       67 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-formatr-1.7-r36h6115d3f_2.tar.bz2          166 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-glue-1.4.1-r36hcdcec82_0.tar.bz2           140 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rvcheck-0.1.8-r36h6115d3f_1.tar.bz2         48 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-e1071-1.7_3-r36h0357c0b_1.tar.bz2          832 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gxx_impl_linux-64-7.5.0-h64c220c_13.tar.bz2    19.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-munsell-0.5.0-r36h6115d3f_1003.tar.bz2     246 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-base64enc-0.1_3-r36hcdcec82_1004.tar.bz2      44 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rsqlite-2.2.0-r36h0357c0b_2.tar.bz2        1.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libxau-1.0.9-h14c3975_0.tar.bz2          13 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rlang-0.4.7-r36hcdcec82_0.tar.bz2          1.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rcppeigen-0.3.3.7.0-r36h51c796c_2.tar.bz2     1.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-biocparallel-1.20.0-r36he1b5a44_0.tar.bz2     1.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libice-1.0.10-h516909a_0.tar.bz2         57 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gcc_linux-64-7.5.0-hf34d7eb_27.tar.bz2        23 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rematch-1.0.1-r36h6115d3f_1003.tar.bz2      19 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gsl-2.6-h294904e_0.tar.bz2                   3.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-pkgload-1.1.0-r36h0357c0b_0.tar.bz2        168 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-shiny-1.5.0-r36h6115d3f_0.tar.bz2          4.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-praise-1.0.0-r36h6115d3f_1004.tar.bz2       23 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-tibble-3.0.3-r36hcdcec82_0.tar.bz2         385 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-blob-1.2.1-r36h6115d3f_1.tar.bz2            63 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-widgettools-1.64.0-r36_0.tar.bz2     312 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-generics-0.0.2-r36h6115d3f_1003.tar.bz2      77 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-backports-1.1.9-r36hcdcec82_0.tar.bz2       88 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-magrittr-1.5-r36h6115d3f_1003.tar.bz2      167 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-stringi-1.4.6-r36h604b29c_3.tar.bz2        781 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-xml-3.99_0.3-r36hcdcec82_1.tar.bz2         1.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gfortran_linux-64-7.5.0-h09487f9_20.tar.bz2      21 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libgomp-9.3.0-h24d8f2e_16.tar.bz2            378 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) pthread-stubs-0.4-h14c3975_1001.tar.bz2        5 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-mfuzz-2.46.0-r36_0.tar.bz2      709 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rcurl-1.98_1.2-r36hcdcec82_1.tar.bz2       921 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-xtable-1.8_4-r36h6115d3f_3.tar.bz2         699 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-lambda.r-1.2.4-r36h6115d3f_1.tar.bz2       120 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libxrender-0.9.10-h516909a_1002.tar.bz2      31 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libgfortran-ng-7.5.0-hdf63c60_16.tar.bz2     1.3 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) binutils_impl_linux-64-2.34-h53a641e_7.tar.bz2     9.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-bitops-1.0_6-r36hcdcec82_1004.tar.bz2       39 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-gtable-0.3.0-r36h6115d3f_3.tar.bz2         423 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-pkgconfig-2.0.3-r36h6115d3f_1.tar.bz2       24 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rjava-0.9_13-r36hcdcec82_3.tar.bz2         775 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) graphite2-1.3.13-he1b5a44_1001.tar.bz2       102 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-limma-3.42.0-r36h516909a_0.tar.bz2     2.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-withr-2.2.0-r36h6115d3f_1.tar.bz2          227 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-openssl-1.4.2-r36he5c4762_0.tar.bz2        1.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-fastmatch-1.1_0-r36hcdcec82_1005.tar.bz2      46 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-mass-7.3_52-r36hcdcec82_0.tar.bz2          1.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-dose-3.12.0-r36_0.tar.bz2       3.4 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-viridislite-0.3.0-r36h6115d3f_1003.tar.bz2      64 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-cowplot-1.0.0-r36h6115d3f_2.tar.bz2        1.3 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) vsclust-0.86-r36h4333106_0.tar.bz2           1.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-crayon-1.3.4-r36h6115d3f_1003.tar.bz2      747 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-plyr-1.8.6-r36h0357c0b_1.tar.bz2           833 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-mgcv-1.8_32-r36h7fa42b6_0.tar.bz2          2.9 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) ld_impl_linux-64-2.34-h53a641e_7.tar.bz2     616 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-assertthat-0.2.1-r36h6115d3f_2.tar.bz2      70 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libxext-1.3.4-h516909a_0.tar.bz2         51 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libstdcxx-ng-9.3.0-hdf63c60_16.tar.bz2       4.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-polyclip-1.10_0-r36h0357c0b_2.tar.bz2      128 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libuuid-2.32.1-h14c3975_1000.tar.bz2          26 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-libx11-1.6.11-h516909a_0.tar.bz2        920 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) xorg-xextproto-7.3.0-h14c3975_1002.tar.bz2      27 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) _r-mutex-1.0.1-anacondar_1.tar.bz2             3 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-testthat-2.3.2-r36h0357c0b_1.tar.bz2       1.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-gosemsim-2.12.0-r36he1b5a44_0.tar.bz2     796 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-genefilter-1.68.0-r36hc99cbb1_0.tar.bz2     1.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-curl-4.3-r36hcdcec82_1.tar.bz2             702 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-sys-3.4-r36hcdcec82_0.tar.bz2               48 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) libtiff-4.1.0-hc7e4089_6.tar.bz2             668 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) glib-2.65.0-h6f030ca_0.tar.bz2               3.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-rbgl-1.62.1-r36he1b5a44_0.tar.bz2     2.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-matrixstats-0.56.0-r36hcdcec82_1.tar.bz2     925 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-dplyr-1.0.2-r36h0357c0b_0.tar.bz2          1.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) sed-4.8-hbfbb72e_0.tar.bz2                   263 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-pillar-1.4.6-r36h6115d3f_0.tar.bz2         194 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) setuptools-49.6.0-py38h32f6830_0.tar.bz2     951 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-promises-1.1.1-r36h0357c0b_0.tar.bz2       1.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-cellranger-1.1.0-r36h6115d3f_1003.tar.bz2     108 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-futile.options-1.0.1-r36h6115d3f_1002.tar.bz2      27 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) tk-8.6.10-hed695b0_0.tar.bz2                 3.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-evaluate-0.14-r36h6115d3f_2.tar.bz2         81 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-gridextra-2.3-r36h6115d3f_1003.tar.bz2     1.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-r6-2.4.1-r36h6115d3f_1.tar.bz2              63 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ellipsis-0.3.1-r36hcdcec82_0.tar.bz2        49 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-utf8-1.1.4-r36hcdcec82_1003.tar.bz2        161 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gcc_impl_linux-64-7.5.0-hda68d29_13.tar.bz2    42.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-graph-1.64.0-r36h516909a_0.tar.bz2     1.7 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rstudioapi-0.11-r36h6115d3f_1.tar.bz2      267 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-reshape2-1.4.4-r36h0357c0b_1.tar.bz2       135 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-iranges-2.20.0-r36h516909a_0.tar.bz2     2.4 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-data.table-1.12.8-r36hcdcec82_1.tar.bz2     1.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) make-4.3-h516909a_0.tar.bz2                  505 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-survival-3.2_3-r36hcdcec82_0.tar.bz2       7.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-do.db-2.9-r36_7.tar.bz2           7 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-category-2.52.0-r36_0.tar.bz2     1.2 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-bit64-4.0.2-r36hcdcec82_0.tar.bz2          510 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-readxl-1.3.1-r36hde08347_4.tar.bz2         856 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-scales-1.1.1-r36h6115d3f_0.tar.bz2         558 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-lifecycle-0.2.0-r36h6115d3f_1.tar.bz2      112 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) cairo-1.16.0-h3fc0475_1005.tar.bz2           1.5 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-fansi-0.4.1-r36hcdcec82_1.tar.bz2          196 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-europepmc-0.4-r36h6115d3f_0.tar.bz2        251 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-digest-0.6.25-r36h0357c0b_2.tar.bz2        199 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-httr-1.4.2-r36h6115d3f_0.tar.bz2           493 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-zeallot-0.1.0-r36h6115d3f_1002.tar.bz2      62 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-processx-3.4.3-r36hcdcec82_0.tar.bz2       297 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-tkwidgets-1.64.0-r36_0.tar.bz2     568 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-memoise-1.1.0-r36h6115d3f_1004.tar.bz2      42 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-prettyunits-1.1.1-r36h6115d3f_1.tar.bz2      41 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) certifi-2020.6.20-py38h32f6830_0.tar.bz2     151 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-plogr-0.2.0-r36h6115d3f_1003.tar.bz2        19 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-desc-1.2.0-r36h6115d3f_1003.tar.bz2        290 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-annotate-1.64.0-r36_0.tar.bz2     2.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) pixman-0.38.0-h516909a_1003.tar.bz2          594 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-rcolorbrewer-1.1_2-r36h6115d3f_1003.tar.bz2      59 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-farver-2.0.3-r36h0357c0b_1.tar.bz2         1.4 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-bit-4.0.4-r36hcdcec82_0.tar.bz2            611 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) openjdk-8.0.192-h516909a_1005.tar.bz2       69.6 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) tktable-2.10-h555a92e_3.tar.bz2               89 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) fribidi-1.0.10-h516909a_0.tar.bz2            113 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-httpuv-1.5.4-r36h0357c0b_0.tar.bz2         867 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-htmltools-0.5.0-r36h0357c0b_0.tar.bz2      235 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-fastmap-1.0.1-r36h0357c0b_1.tar.bz2         55 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bioconductor-clusterprofiler-3.14.0-r36_0.tar.bz2     561 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) python_abi-3.8-1_cp38.tar.bz2                  4 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-stringr-1.4.0-r36h6115d3f_2.tar.bz2        209 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-matrix-1.2_18-r36h7fa42b6_3.tar.bz2        3.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-jsonlite-1.7.0-r36hcdcec82_0.tar.bz2       1.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gfortran_impl_linux-64-7.5.0-h1104b78_16.tar.bz2     9.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gxx_linux-64-7.5.0-h09487f9_20.tar.bz2        21 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) gmp-6.2.0-he1b5a44_2.tar.bz2                 811 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-igraph-1.2.5-r36hd626d4e_1.tar.bz2         3.8 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-nlme-3.1_149-r36h9bbef5b_0.tar.bz2         2.3 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-lattice-0.20_41-r36hcdcec82_2.tar.bz2      1.1 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-ggplotify-0.0.5-r36h6115d3f_1.tar.bz2      212 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) bwidget-1.9.14-0.tar.bz2                     119 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) jpeg-9d-h516909a_0.tar.bz2                   266 KB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) r-colorspace-1.4_1-r36hcdcec82_2.tar.bz2     2.4 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) [0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) ---------------------------------------------------[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Total:                                     503.0 MB[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) [0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Proceed ([y]/n)?[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-shinyjs-1.1-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-askpass-1.1-r36hcdcec82_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gxx_impl_linux-64-7.5.0-hdf63c60_6.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-annotationforge-1.28.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rprojroot-1.3_2-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-gseabase-1.48.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-biocmanager-1.30.10-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-urltools-1.7.3-r36h0357c0b_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-renderproto-0.11.1-h14c3975_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libsm-1.2.3-h84519dc_1000.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-progress-1.2.2-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-viridis-0.5.1-r36h6115d3f_1004.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-purrr-0.3.4-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-class-7.3_17-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-biobase-2.46.0-r36h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libgcc-ng-9.3.0-h24d8f2e_16.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-kbproto-1.0.7-h14c3975_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-hms-0.5.3-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-enrichplot-1.6.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-qvalue-2.18.0-r36_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-later-1.1.0.1-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gcc_linux-64-7.5.0-h09487f9_20.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-tweenr-1.0.1-r36h0357c0b_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-graphlayouts-0.7.0-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed c-ares-1.16.1-h516909a_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-futile.logger-1.4.3-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libpng-1.6.37-hed695b0_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-annotationdbi-1.48.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-bh-1.72.0_3-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-tidygraph-1.2.0-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-tidyselect-1.1.0-r36h6115d3f_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gfortran_impl_linux-64-7.5.0-hdf63c60_6.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-rgraphviz-2.30.0-r36he1b5a44_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-tidyr-1.1.1-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed pango-1.42.4-h7062337_4.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libxdmcp-1.1.3-h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rcpp-1.0.5-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ggforce-0.3.2-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-dyndoc-1.64.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-biocgenerics-0.32.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-sourcetools-0.1.7-r36he1b5a44_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-yaml-2.2.1-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-shinythemes-1.1.2-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libwebp-base-1.1.0-h516909a_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-callr-3.4.3-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-gostats-2.52.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-xproto-7.0.31-h14c3975_1007.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-s4vectors-0.24.0-r36h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-dbi-1.1.0-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ggraph-2.0.3-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-xml2-1.3.2-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-gridgraphics-0.5_0-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rcpparmadillo-0.9.900.2.0-r36h51c796c_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-rdavidwebservice-1.24.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ggridges-0.5.2-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed binutils_linux-64-2.34-hc952b39_20.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-triebeard-0.3.0-r36he1b5a44_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-base-3.6.3-he766273_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gcc_impl_linux-64-7.5.0-hd420e75_6.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-cli-2.0.2-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-snow-0.4_3-r36h6115d3f_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-pkgbuild-1.1.0-r36h6115d3f_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed freetype-2.10.2-he06d7ca_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bzip2-1.0.8-h516909a_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-fgsea-1.12.0-r36he1b5a44_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-vctrs-0.3.2-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed python-3.8.5-h1103e12_5_cpython.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed fontconfig-2.13.1-h1056068_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed harfbuzz-2.7.1-hee91db6_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ggrepel-0.8.2-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libxcb-1.13-h14c3975_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ggplot2-3.3.2-r36h6115d3f_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-isoband-0.2.2-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-mime-0.9-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gxx_linux-64-7.5.0-ha781d05_27.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ps-1.3.4-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-go.db-3.10.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gfortran_linux-64-7.5.0-ha781d05_27.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-commonmark-1.7-r36hcdcec82_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-labeling-0.3-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-formatr-1.7-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-glue-1.4.1-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rvcheck-0.1.8-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-e1071-1.7_3-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gxx_impl_linux-64-7.5.0-h64c220c_13.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-munsell-0.5.0-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-base64enc-0.1_3-r36hcdcec82_1004.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rsqlite-2.2.0-r36h0357c0b_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libxau-1.0.9-h14c3975_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rlang-0.4.7-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rcppeigen-0.3.3.7.0-r36h51c796c_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-biocparallel-1.20.0-r36he1b5a44_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libice-1.0.10-h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gcc_linux-64-7.5.0-hf34d7eb_27.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rematch-1.0.1-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gsl-2.6-h294904e_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-pkgload-1.1.0-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-shiny-1.5.0-r36h6115d3f_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-praise-1.0.0-r36h6115d3f_1004.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-tibble-3.0.3-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-blob-1.2.1-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-widgettools-1.64.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-generics-0.0.2-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-backports-1.1.9-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-magrittr-1.5-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-stringi-1.4.6-r36h604b29c_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-xml-3.99_0.3-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gfortran_linux-64-7.5.0-h09487f9_20.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libgomp-9.3.0-h24d8f2e_16.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed pthread-stubs-0.4-h14c3975_1001.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-mfuzz-2.46.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rcurl-1.98_1.2-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-xtable-1.8_4-r36h6115d3f_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-lambda.r-1.2.4-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libxrender-0.9.10-h516909a_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libgfortran-ng-7.5.0-hdf63c60_16.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed binutils_impl_linux-64-2.34-h53a641e_7.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-bitops-1.0_6-r36hcdcec82_1004.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-gtable-0.3.0-r36h6115d3f_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-pkgconfig-2.0.3-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rjava-0.9_13-r36hcdcec82_3.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed graphite2-1.3.13-he1b5a44_1001.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-limma-3.42.0-r36h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-withr-2.2.0-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-openssl-1.4.2-r36he5c4762_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-fastmatch-1.1_0-r36hcdcec82_1005.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-mass-7.3_52-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-dose-3.12.0-r36_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-viridislite-0.3.0-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-cowplot-1.0.0-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed vsclust-0.86-r36h4333106_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-crayon-1.3.4-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-plyr-1.8.6-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-mgcv-1.8_32-r36h7fa42b6_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed ld_impl_linux-64-2.34-h53a641e_7.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-assertthat-0.2.1-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libxext-1.3.4-h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libstdcxx-ng-9.3.0-hdf63c60_16.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-polyclip-1.10_0-r36h0357c0b_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libuuid-2.32.1-h14c3975_1000.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-libx11-1.6.11-h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed xorg-xextproto-7.3.0-h14c3975_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed _r-mutex-1.0.1-anacondar_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-testthat-2.3.2-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-gosemsim-2.12.0-r36he1b5a44_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-genefilter-1.68.0-r36hc99cbb1_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-curl-4.3-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-sys-3.4-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed libtiff-4.1.0-hc7e4089_6.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed glib-2.65.0-h6f030ca_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-rbgl-1.62.1-r36he1b5a44_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-matrixstats-0.56.0-r36hcdcec82_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-dplyr-1.0.2-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed sed-4.8-hbfbb72e_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-pillar-1.4.6-r36h6115d3f_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed setuptools-49.6.0-py38h32f6830_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-promises-1.1.1-r36h0357c0b_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-cellranger-1.1.0-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-futile.options-1.0.1-r36h6115d3f_1002.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed tk-8.6.10-hed695b0_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-evaluate-0.14-r36h6115d3f_2.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-gridextra-2.3-r36h6115d3f_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-r6-2.4.1-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-ellipsis-0.3.1-r36hcdcec82_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-utf8-1.1.4-r36hcdcec82_1003.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed gcc_impl_linux-64-7.5.0-hda68d29_13.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-graph-1.64.0-r36h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-rstudioapi-0.11-r36h6115d3f_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-reshape2-1.4.4-r36h0357c0b_1.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-iranges-2.20.0-r36h516909a_0.tar.bz2[0m
12:48:26 [32mBIOCONDA INFO[0m (OUT) Removed r-data.table-1.12.8-r36hcdcec82_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed make-4.3-h516909a_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-survival-3.2_3-r36hcdcec82_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-do.db-2.9-r36_7.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-category-2.52.0-r36_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-bit64-4.0.2-r36hcdcec82_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-readxl-1.3.1-r36hde08347_4.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-scales-1.1.1-r36h6115d3f_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-lifecycle-0.2.0-r36h6115d3f_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed cairo-1.16.0-h3fc0475_1005.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-fansi-0.4.1-r36hcdcec82_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-europepmc-0.4-r36h6115d3f_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-digest-0.6.25-r36h0357c0b_2.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-httr-1.4.2-r36h6115d3f_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-zeallot-0.1.0-r36h6115d3f_1002.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-processx-3.4.3-r36hcdcec82_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-tkwidgets-1.64.0-r36_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-memoise-1.1.0-r36h6115d3f_1004.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-prettyunits-1.1.1-r36h6115d3f_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed certifi-2020.6.20-py38h32f6830_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-plogr-0.2.0-r36h6115d3f_1003.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-desc-1.2.0-r36h6115d3f_1003.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-annotate-1.64.0-r36_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed pixman-0.38.0-h516909a_1003.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-rcolorbrewer-1.1_2-r36h6115d3f_1003.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-farver-2.0.3-r36h0357c0b_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-bit-4.0.4-r36hcdcec82_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed openjdk-8.0.192-h516909a_1005.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed tktable-2.10-h555a92e_3.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed fribidi-1.0.10-h516909a_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-httpuv-1.5.4-r36h0357c0b_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-htmltools-0.5.0-r36h0357c0b_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-fastmap-1.0.1-r36h0357c0b_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed bioconductor-clusterprofiler-3.14.0-r36_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed python_abi-3.8-1_cp38.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-stringr-1.4.0-r36h6115d3f_2.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-matrix-1.2_18-r36h7fa42b6_3.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-jsonlite-1.7.0-r36hcdcec82_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed gfortran_impl_linux-64-7.5.0-h1104b78_16.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed gxx_linux-64-7.5.0-h09487f9_20.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed gmp-6.2.0-he1b5a44_2.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-igraph-1.2.5-r36hd626d4e_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-nlme-3.1_149-r36h9bbef5b_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-lattice-0.20_41-r36hcdcec82_2.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-ggplotify-0.0.5-r36h6115d3f_1.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed bwidget-1.9.14-0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed jpeg-9d-h516909a_0.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Removed r-colorspace-1.4_1-r36hcdcec82_2.tar.bz2[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) WARNING: /root/.conda/pkgs does not exist[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Cache location: /opt/conda/pkgs[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Will remove the following packages:[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) /opt/conda/pkgs[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ---------------[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) [0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gfortran_impl_linux-64-9.3.0-hde52e87_15    29.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) decorator-4.4.2-py_0                          34 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) binutils_impl_linux-64-2.34-h2122c62_9      28.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) attrs-20.1.0-pyh9f0ad1d_0                    178 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) patch-2.7.6-h14c3975_1001                    295 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) anaconda-client-1.7.2-py_0                   343 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgcc-ng-9.3.0-h24d8f2e_15                 24.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) py-lief-0.10.1-py37h3340039_0                5.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pytz-2020.1-pyh9f0ad1d_0                     1.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libstdcxx-ng-9.3.0-hdf63c60_15              12.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) sysroot_linux-64-2.12-h77966d4_13          126.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgcc-devel_linux-64-9.3.0-hfd08b2a_15      7.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libnghttp2-1.41.0-hab1572f_1                 2.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) curl-7.71.1-he644dc0_5                       261 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) liblief-0.10.1-he1b5a44_0                    7.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) python-libarchive-c-2.9-py37_0               709 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) tqdm-4.48.2-pyh9f0ad1d_0                     217 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) python-3.7.8-h6f2ec95_1_cpython            103.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ncurses-6.2-he1b5a44_1                       4.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgfortran-ng-9.3.0-hdf63c60_15             9.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libssh2-1.9.0-hab1572f_5                     817 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) yaml-0.2.5-h516909a_0                        360 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gettext-0.19.8.1-hc5be6a0_1002              14.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gxx_impl_linux-64-9.3.0-hde52e87_15         31.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) beautifulsoup4-4.9.1-py_1                    432 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) traitlets-4.3.3-py37hc8dfbb8_1               632 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pyrsistent-0.16.0-py37h8f50634_0             379 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) wheel-0.35.1-pyh9f0ad1d_0                    108 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) requests-2.24.0-pyh9f0ad1d_0                 195 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libxml2-2.9.10-h68273f3_2                    8.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) openssl-1.1.1g-h516909a_1                    6.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) krb5-1.17.1-hfafb76e_2                       5.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ipython_genutils-0.2.0-py_1                   74 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) tini-0.18.0-h14c3975_1001                     36 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) jupyter_core-4.6.3-py37hc8dfbb8_1            355 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libedit-3.1.20191231-he28a2e2_2              358 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) _openmp_mutex-4.5-1_gnu                       93 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) glob2-0.7-py_0                                33 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) readline-8.0-he28a2e2_2                      1.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) sqlite-3.33.0-h4cf870e_0                     3.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) markupsafe-1.1.1-py37h8f50634_1               82 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gcc_impl_linux-64-9.3.0-ha2fd2e4_15        133.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) patchelf-0.11-he1b5a44_0                     211 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) conda-build-3.19.2-py37hc8dfbb8_4            2.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) conda-4.8.4-py37hc8dfbb8_2                  11.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) cffi-1.14.1-py37h2b28604_0                   839 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) lz4-c-1.9.2-he1b5a44_3                       689 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) perl-5.26.2-h516909a_1006                   70.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) icu-67.1-he1b5a44_0                         39.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) zstd-1.4.5-h6597ccf_2                        1.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gcc_linux-64-9.3.0-h44160b2_27               119 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) urllib3-1.25.10-py_0                         409 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) _libgcc_mutex-0.1-conda_forge                  6 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) psutil-5.7.2-py37h8f50634_0                  1.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ca-certificates-2020.6.20-hecda079_0         286 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libffi-3.2.1-he1b5a44_1007                   168 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) six-1.15.0-pyh9f0ad1d_0                       49 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) c-ares-1.16.1-h516909a_0                     421 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) idna-2.10-pyh9f0ad1d_0                       281 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) filelock-3.0.12-pyh9f0ad1d_0                  31 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) setuptools-49.6.0-py37hc8dfbb8_0             3.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libarchive-3.3.3-hddc7a2b_1008               4.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ripgrep-12.1.1-h516909a_0                    5.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) conda-package-handling-1.7.0-py37h8f50634_4     6.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) kernel-headers_linux-64-2.6.32-h77966d4_13     2.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) soupsieve-2.0.1-py_1                         135 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libstdcxx-devel_linux-64-9.3.0-h4084dd6_15    48.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) git-2.28.0-pl526h5e3e691_1                  50.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pkginfo-1.5.0.1-py_0                         109 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ld_impl_linux-64-2.34-hc38a660_9             2.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) lzo-2.10-h516909a_1000                       1.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pyyaml-5.3.1-py37h8f50634_0                  669 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pycparser-2.20-pyh9f0ad1d_2                  616 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) su-exec-0.2-h516909a_1002                     30 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) jsonschema-3.2.0-py37hc8dfbb8_1              428 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) zipp-3.1.0-py_0                               30 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pip-20.2.2-py_0                              4.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gxx_linux-64-9.3.0-ha9dd585_27               114 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) nbformat-5.0.7-py_0                          479 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) cryptography-3.0-py37hb09aad4_0              3.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) binutils_linux-64-2.34-h47ac705_27           110 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) importlib-metadata-1.7.0-py37hc8dfbb8_0      160 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xz-5.2.5-h516909a_1                          1.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) python-dateutil-2.8.1-py_0                   447 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) clyent-1.2.2-py_1                             33 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libev-4.33-h516909a_0                        403 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pcre-8.44-he1b5a44_0                         1.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgomp-9.3.0-h24d8f2e_15                    1.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) zlib-1.2.11-h516909a_1007                    379 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) expat-2.2.9-he1b5a44_2                       878 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) certifi-2020.6.20-py37hc8dfbb8_0             299 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libcurl-7.71.1-hcdd3856_5                    879 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libiconv-1.16-h516909a_0                     2.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) jinja2-2.11.2-pyh9f0ad1d_0                   459 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) brotlipy-0.7.0-py37h8f50634_1000             809 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gfortran_linux-64-9.3.0-ha9dd585_27          113 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gmp-6.2.0-he1b5a44_2                         3.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-base-3.6.3-he766273_3                     36.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) make-4.3-h516909a_0                          2.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) openjdk-8.0.192-h516909a_1005              173.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-triebeard-0.3.0-r36he1b5a44_1003           499 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gfortran_linux-64-7.5.0-ha781d05_27          113 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-biocgenerics-0.32.0-r36_0       905 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-gtable-0.3.0-r36h6115d3f_3                 2.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-annotationdbi-1.48.0-r36_0      8.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-xml-3.99_0.3-r36hcdcec82_1                 2.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-pkgbuild-1.1.0-r36h6115d3f_0               202 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ggridges-0.5.2-r36h6115d3f_2               3.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-fansi-0.4.1-r36hcdcec82_1                  302 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libxdmcp-1.1.3-h516909a_0                52 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-pillar-1.4.6-r36h6115d3f_0                 255 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gsl-2.6-h294904e_0                          14.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgfortran-ng-7.5.0-hdf63c60_16             5.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rvcheck-0.1.8-r36h6115d3f_1                 70 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ggplot2-3.3.2-r36h6115d3f_0                4.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libopenblas-0.3.10-pthreads_hb3c22a3_4      29.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-polyclip-1.10_0-r36h0357c0b_2              244 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-scales-1.1.1-r36h6115d3f_0                 628 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-xml2-1.3.2-r36h0357c0b_1                   420 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-futile.logger-1.4.3-r36h6115d3f_1003       140 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-httr-1.4.2-r36h6115d3f_0                   705 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-farver-2.0.3-r36h0357c0b_1                 2.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-prettyunits-1.1.1-r36h6115d3f_1             54 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-purrr-0.3.4-r36hcdcec82_1                  567 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-snow-0.4_3-r36h6115d3f_1002                168 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gfortran_impl_linux-64-7.5.0-h1104b78_16    25.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-tkwidgets-1.64.0-r36_0          630 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libpng-1.6.37-hed695b0_2                     1.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gcc_linux-64-7.5.0-h09487f9_20               110 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-magrittr-1.5-r36h6115d3f_1003              244 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ggforce-0.3.2-r36h0357c0b_0                2.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-isoband-0.2.2-r36h0357c0b_0                3.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-matrix-1.2_18-r36h7fa42b6_3                5.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-stringi-1.4.6-r36h604b29c_3                1.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-shinyjs-1.1-r36h6115d3f_1                  1.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-stringr-1.4.0-r36h6115d3f_2                371 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-desc-1.2.0-r36h6115d3f_1003                331 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-e1071-1.7_3-r36h0357c0b_1                  949 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gcc_impl_linux-64-7.5.0-hd420e75_6         211.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libcblas-3.8.0-17_openblas                    38 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-generics-0.0.2-r36h6115d3f_1003            110 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libxext-1.3.4-h516909a_0                182 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-xtable-1.8_4-r36h6115d3f_3                 817 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) harfbuzz-2.7.1-hee91db6_0                    6.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) tktable-2.10-h555a92e_3                      298 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-tidygraph-1.2.0-r36h0357c0b_0              664 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgomp-9.3.0-h24d8f2e_16                    1.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-tibble-3.0.3-r36hcdcec82_0                 689 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rstudioapi-0.11-r36h6115d3f_1              408 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gxx_linux-64-7.5.0-h09487f9_20               106 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) vsclust-0.86-r36h4333106_0                   2.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-digest-0.6.25-r36h0357c0b_2                384 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libwebp-base-1.1.0-h516909a_3                2.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-jsonlite-1.7.0-r36hcdcec82_0               2.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rjava-0.9_13-r36hcdcec82_3                 1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) python_abi-3.8-1_cp38                         10 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-cellranger-1.1.0-r36h6115d3f_1003          139 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) python-3.8.5-h1103e12_5_cpython             69.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-zeallot-0.1.0-r36h6115d3f_1002             137 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-pkgconfig-2.0.3-r36h6115d3f_1               44 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-nlme-3.1_149-r36h9bbef5b_0                 2.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-data.table-1.12.8-r36hcdcec82_1            2.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-clusterprofiler-3.14.0-r36_0     907 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-progress-1.2.2-r36h6115d3f_2               130 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rcurl-1.98_1.2-r36hcdcec82_1               1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-limma-3.42.0-r36h516909a_0      3.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-fastmatch-1.1_0-r36hcdcec82_1005            91 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pthread-stubs-0.4-h14c3975_1001               12 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-gseabase-1.48.0-r36_0           1.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-curl-4.3-r36hcdcec82_1                     1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ggplotify-0.0.5-r36h6115d3f_1              319 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gxx_impl_linux-64-7.5.0-hdf63c60_6          61.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-shiny-1.5.0-r36h6115d3f_0                 10.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-biocparallel-1.20.0-r36he1b5a44_0     1.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-htmltools-0.5.0-r36h0357c0b_0              298 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-vctrs-0.3.2-r36hcdcec82_0                  1.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libstdcxx-ng-9.3.0-hdf63c60_16              12.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) jpeg-9d-h516909a_0                          1005 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-urltools-1.7.3-r36h0357c0b_2               547 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-bh-1.72.0_3-r36h6115d3f_1                110.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) certifi-2020.6.20-py38h32f6830_0             299 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-dyndoc-1.64.0-r36_0             236 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-commonmark-1.7-r36hcdcec82_1002            377 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-gosemsim-2.12.0-r36he1b5a44_0     939 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rprojroot-1.3_2-r36h6115d3f_1003           184 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) cairo-1.16.0-h3fc0475_1005                   6.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-mgcv-1.8_32-r36h7fa42b6_0                  3.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) _r-mutex-1.0.1-anacondar_1                     9 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) binutils_linux-64-2.34-hc952b39_20           102 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-yaml-2.2.1-r36hcdcec82_1                   274 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-processx-3.4.3-r36hcdcec82_0               424 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-annotationforge-1.28.0-r36_0     5.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ps-1.3.4-r36hcdcec82_0                     335 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-hms-0.5.3-r36h6115d3f_1                    173 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libxcb-1.13-h14c3975_1002                    3.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-annotate-1.64.0-r36_0           2.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-gridextra-2.3-r36h6115d3f_1003             1.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-s4vectors-0.24.0-r36h516909a_0     2.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-plogr-0.2.0-r36h6115d3f_1003                49 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) fontconfig-2.13.1-h1056068_1002              1.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-lambda.r-1.2.4-r36h6115d3f_1               139 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-pkgload-1.1.0-r36h0357c0b_0                226 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-bitops-1.0_6-r36hcdcec82_1004               90 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rematch-1.0.1-r36h6115d3f_1003              36 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-dplyr-1.0.2-r36h0357c0b_0                  1.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-kbproto-1.0.7-h14c3975_1002             132 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-munsell-0.5.0-r36h6115d3f_1003             346 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-memoise-1.1.0-r36h6115d3f_1004              59 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-assertthat-0.2.1-r36h6115d3f_2             110 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gcc_linux-64-7.5.0-hf34d7eb_27               119 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-readxl-1.3.1-r36hde08347_4                 1.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rcpparmadillo-0.9.900.2.0-r36h51c796c_0     6.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-bit-4.0.4-r36hcdcec82_0                    984 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) binutils_impl_linux-64-2.34-h53a641e_7      28.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-labeling-0.3-r36h6115d3f_1003               81 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rlang-0.4.7-r36hcdcec82_0                  1.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-bit64-4.0.2-r36hcdcec82_0                  689 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-rdavidwebservice-1.24.0-r36_0    23.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-igraph-1.2.5-r36hd626d4e_1                 6.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-iranges-2.20.0-r36h516909a_0     3.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-cowplot-1.0.0-r36h6115d3f_2                2.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-mass-7.3_52-r36hcdcec82_0                  1.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-crayon-1.3.4-r36h6115d3f_1003              774 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-mfuzz-2.46.0-r36_0              1.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) c-ares-1.16.1-h516909a_3                     413 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-lattice-0.20_41-r36hcdcec82_2              1.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-askpass-1.1-r36hcdcec82_2                   61 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-class-7.3_17-r36hcdcec82_1                 168 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-mime-0.9-r36hcdcec82_1                     104 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gcc_impl_linux-64-7.5.0-hda68d29_13        126.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-shinythemes-1.1.2-r36h6115d3f_2            3.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-callr-3.4.3-r36h6115d3f_1                  453 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-praise-1.0.0-r36h6115d3f_1004               39 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-dbi-1.1.0-r36h6115d3f_1                    1.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ggraph-2.0.3-r36h0357c0b_0                 5.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-tweenr-1.0.1-r36h0357c0b_1002              526 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-rgraphviz-2.30.0-r36he1b5a44_0     2.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) fribidi-1.0.10-h516909a_0                    441 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-do.db-2.9-r36_7                  21 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bzip2-1.0.8-h516909a_3                       1.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) graphite2-1.3.13-he1b5a44_1001               256 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rcpp-1.0.5-r36h0357c0b_0                   8.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-viridis-0.5.1-r36h6115d3f_1004             2.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-qvalue-2.18.0-r36_1             2.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ld_impl_linux-64-2.34-h53a641e_7             2.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) glib-2.65.0-h6f030ca_0                      15.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-gridgraphics-0.5_0-r36h6115d3f_1           377 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-lifecycle-0.2.0-r36h6115d3f_1              215 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-go.db-3.10.0-r36_0               21 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-withr-2.2.0-r36h6115d3f_1                  323 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-xextproto-7.3.0-h14c3975_1002           171 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gfortran_impl_linux-64-7.5.0-hdf63c60_6     26.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-viridislite-0.3.0-r36h6115d3f_1003          83 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ggrepel-0.8.2-r36h0357c0b_1               1022 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rcppeigen-0.3.3.7.0-r36h51c796c_2          7.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-europepmc-0.4-r36h6115d3f_0                411 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-later-1.1.0.1-r36h0357c0b_0                386 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-r6-2.4.1-r36h6115d3f_1                      82 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-fgsea-1.12.0-r36he1b5a44_0      1.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-gostats-2.52.0-r36_0            2.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-dose-3.12.0-r36_0               3.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-tidyselect-1.1.0-r36h6115d3f_0             376 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libblas-3.8.0-17_openblas                     39 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-testthat-2.3.2-r36h0357c0b_1               1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-futile.options-1.0.1-r36h6115d3f_1002       45 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-renderproto-0.11.1-h14c3975_1002         32 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pixman-0.38.0-h516909a_1003                  1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-matrixstats-0.56.0-r36hcdcec82_1           3.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-formatr-1.7-r36h6115d3f_2                  291 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libsm-1.2.3-h84519dc_1000                79 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-cli-2.0.2-r36h6115d3f_1                    468 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-survival-3.2_3-r36hcdcec82_0               8.4 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libuuid-2.32.1-h14c3975_1000                  95 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gfortran_linux-64-7.5.0-h09487f9_20          105 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libtiff-4.1.0-hc7e4089_6                     2.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rcolorbrewer-1.1_2-r36h6115d3f_1003         74 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-blob-1.2.1-r36h6115d3f_1                   103 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-ellipsis-0.3.1-r36hcdcec82_0               106 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-fastmap-1.0.1-r36h0357c0b_1                116 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libxau-1.0.9-h14c3975_0                  37 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-reshape2-1.4.4-r36h0357c0b_1               238 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-rsqlite-2.2.0-r36h0357c0b_2                2.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-xproto-7.0.31-h14c3975_1007             401 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-backports-1.1.9-r36hcdcec82_0              132 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-widgettools-1.64.0-r36_0        413 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-enrichplot-1.6.0-r36_0          224 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-httpuv-1.5.4-r36h0357c0b_0                 1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) tk-8.6.10-hed695b0_0                        10.5 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bwidget-1.9.14-0                             723 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-openssl-1.4.2-r36he5c4762_0                3.1 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-base64enc-0.1_3-r36hcdcec82_1004            91 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-tidyr-1.1.1-r36h0357c0b_1                  1.3 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) freetype-2.10.2-he06d7ca_0                   2.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) setuptools-49.6.0-py38h32f6830_0             3.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-utf8-1.1.4-r36hcdcec82_1003                476 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-rbgl-1.62.1-r36he1b5a44_0       3.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-genefilter-1.68.0-r36hc99cbb1_0     1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-graphlayouts-0.7.0-r36h0357c0b_1           2.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-colorspace-1.4_1-r36hcdcec82_2             3.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-biocmanager-1.30.10-r36h6115d3f_1          161 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) pango-1.42.4-h7062337_4                      3.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-sys-3.4-r36hcdcec82_0                       87 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-plyr-1.8.6-r36h0357c0b_1                   921 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gxx_impl_linux-64-7.5.0-h64c220c_13         61.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libice-1.0.10-h516909a_0                168 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) libgcc-ng-9.3.0-h24d8f2e_16                 24.6 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-sourcetools-0.1.7-r36he1b5a44_1002         154 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) sed-4.8-hbfbb72e_0                           962 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) gxx_linux-64-7.5.0-ha781d05_27               114 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-graph-1.64.0-r36h516909a_0      2.2 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-promises-1.1.1-r36h0357c0b_0               1.9 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libx11-1.6.11-h516909a_0                3.0 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) xorg-libxrender-0.9.10-h516909a_1002          98 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-evaluate-0.14-r36h6115d3f_2                104 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) liblapack-3.8.0-17_openblas                   38 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-category-2.52.0-r36_0           1.7 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) bioconductor-biobase-2.46.0-r36h516909a_0     2.8 MB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) r-glue-1.4.1-r36hcdcec82_0                   220 KB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) [0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) ---------------------------------------------------[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Total:                                      2.14 GB[0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) [0m
12:48:28 [32mBIOCONDA INFO[0m (OUT) Proceed ([y]/n)?[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gfortran_impl_linux-64-9.3.0-hde52e87_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing decorator-4.4.2-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing binutils_impl_linux-64-2.34-h2122c62_9[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing attrs-20.1.0-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing patch-2.7.6-h14c3975_1001[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing anaconda-client-1.7.2-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libgcc-ng-9.3.0-h24d8f2e_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing py-lief-0.10.1-py37h3340039_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pytz-2020.1-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libstdcxx-ng-9.3.0-hdf63c60_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing sysroot_linux-64-2.12-h77966d4_13[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libgcc-devel_linux-64-9.3.0-hfd08b2a_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libnghttp2-1.41.0-hab1572f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing curl-7.71.1-he644dc0_5[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing liblief-0.10.1-he1b5a44_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing python-libarchive-c-2.9-py37_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing tqdm-4.48.2-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing python-3.7.8-h6f2ec95_1_cpython[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing ncurses-6.2-he1b5a44_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libgfortran-ng-9.3.0-hdf63c60_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libssh2-1.9.0-hab1572f_5[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing yaml-0.2.5-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gettext-0.19.8.1-hc5be6a0_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gxx_impl_linux-64-9.3.0-hde52e87_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing beautifulsoup4-4.9.1-py_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing traitlets-4.3.3-py37hc8dfbb8_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pyrsistent-0.16.0-py37h8f50634_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing wheel-0.35.1-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing requests-2.24.0-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libxml2-2.9.10-h68273f3_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing openssl-1.1.1g-h516909a_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing krb5-1.17.1-hfafb76e_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing ipython_genutils-0.2.0-py_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing tini-0.18.0-h14c3975_1001[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing jupyter_core-4.6.3-py37hc8dfbb8_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libedit-3.1.20191231-he28a2e2_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing _openmp_mutex-4.5-1_gnu[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing glob2-0.7-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing readline-8.0-he28a2e2_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing sqlite-3.33.0-h4cf870e_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing markupsafe-1.1.1-py37h8f50634_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gcc_impl_linux-64-9.3.0-ha2fd2e4_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing patchelf-0.11-he1b5a44_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing conda-build-3.19.2-py37hc8dfbb8_4[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing conda-4.8.4-py37hc8dfbb8_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing cffi-1.14.1-py37h2b28604_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing lz4-c-1.9.2-he1b5a44_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing perl-5.26.2-h516909a_1006[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing icu-67.1-he1b5a44_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing zstd-1.4.5-h6597ccf_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gcc_linux-64-9.3.0-h44160b2_27[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing urllib3-1.25.10-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing _libgcc_mutex-0.1-conda_forge[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing psutil-5.7.2-py37h8f50634_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing ca-certificates-2020.6.20-hecda079_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libffi-3.2.1-he1b5a44_1007[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing six-1.15.0-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing c-ares-1.16.1-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing idna-2.10-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing filelock-3.0.12-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing setuptools-49.6.0-py37hc8dfbb8_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libarchive-3.3.3-hddc7a2b_1008[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing ripgrep-12.1.1-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing conda-package-handling-1.7.0-py37h8f50634_4[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing kernel-headers_linux-64-2.6.32-h77966d4_13[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing soupsieve-2.0.1-py_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libstdcxx-devel_linux-64-9.3.0-h4084dd6_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing git-2.28.0-pl526h5e3e691_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pkginfo-1.5.0.1-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing ld_impl_linux-64-2.34-hc38a660_9[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing lzo-2.10-h516909a_1000[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pyyaml-5.3.1-py37h8f50634_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pycparser-2.20-pyh9f0ad1d_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing su-exec-0.2-h516909a_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing jsonschema-3.2.0-py37hc8dfbb8_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing zipp-3.1.0-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pip-20.2.2-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gxx_linux-64-9.3.0-ha9dd585_27[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing nbformat-5.0.7-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing cryptography-3.0-py37hb09aad4_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing binutils_linux-64-2.34-h47ac705_27[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing importlib-metadata-1.7.0-py37hc8dfbb8_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing xz-5.2.5-h516909a_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing python-dateutil-2.8.1-py_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing clyent-1.2.2-py_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libev-4.33-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pcre-8.44-he1b5a44_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libgomp-9.3.0-h24d8f2e_15[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing zlib-1.2.11-h516909a_1007[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing expat-2.2.9-he1b5a44_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing certifi-2020.6.20-py37hc8dfbb8_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libcurl-7.71.1-hcdd3856_5[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libiconv-1.16-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing jinja2-2.11.2-pyh9f0ad1d_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing brotlipy-0.7.0-py37h8f50634_1000[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gfortran_linux-64-9.3.0-ha9dd585_27[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gmp-6.2.0-he1b5a44_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-base-3.6.3-he766273_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing make-4.3-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing openjdk-8.0.192-h516909a_1005[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-triebeard-0.3.0-r36he1b5a44_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gfortran_linux-64-7.5.0-ha781d05_27[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-biocgenerics-0.32.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-gtable-0.3.0-r36h6115d3f_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-annotationdbi-1.48.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-xml-3.99_0.3-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-pkgbuild-1.1.0-r36h6115d3f_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-ggridges-0.5.2-r36h6115d3f_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-fansi-0.4.1-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing xorg-libxdmcp-1.1.3-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-pillar-1.4.6-r36h6115d3f_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gsl-2.6-h294904e_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libgfortran-ng-7.5.0-hdf63c60_16[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-rvcheck-0.1.8-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-ggplot2-3.3.2-r36h6115d3f_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libopenblas-0.3.10-pthreads_hb3c22a3_4[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-polyclip-1.10_0-r36h0357c0b_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-scales-1.1.1-r36h6115d3f_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-xml2-1.3.2-r36h0357c0b_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-futile.logger-1.4.3-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-httr-1.4.2-r36h6115d3f_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-farver-2.0.3-r36h0357c0b_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-prettyunits-1.1.1-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-purrr-0.3.4-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-snow-0.4_3-r36h6115d3f_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gfortran_impl_linux-64-7.5.0-h1104b78_16[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-tkwidgets-1.64.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libpng-1.6.37-hed695b0_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gcc_linux-64-7.5.0-h09487f9_20[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-magrittr-1.5-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-ggforce-0.3.2-r36h0357c0b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-isoband-0.2.2-r36h0357c0b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-matrix-1.2_18-r36h7fa42b6_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-stringi-1.4.6-r36h604b29c_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-shinyjs-1.1-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-stringr-1.4.0-r36h6115d3f_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-desc-1.2.0-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-e1071-1.7_3-r36h0357c0b_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gcc_impl_linux-64-7.5.0-hd420e75_6[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libcblas-3.8.0-17_openblas[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-generics-0.0.2-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing xorg-libxext-1.3.4-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-xtable-1.8_4-r36h6115d3f_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing harfbuzz-2.7.1-hee91db6_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing tktable-2.10-h555a92e_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-tidygraph-1.2.0-r36h0357c0b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libgomp-9.3.0-h24d8f2e_16[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-tibble-3.0.3-r36hcdcec82_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-rstudioapi-0.11-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gxx_linux-64-7.5.0-h09487f9_20[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing vsclust-0.86-r36h4333106_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-digest-0.6.25-r36h0357c0b_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libwebp-base-1.1.0-h516909a_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-jsonlite-1.7.0-r36hcdcec82_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-rjava-0.9_13-r36hcdcec82_3[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing python_abi-3.8-1_cp38[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-cellranger-1.1.0-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing python-3.8.5-h1103e12_5_cpython[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-zeallot-0.1.0-r36h6115d3f_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-pkgconfig-2.0.3-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-nlme-3.1_149-r36h9bbef5b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-data.table-1.12.8-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-clusterprofiler-3.14.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-progress-1.2.2-r36h6115d3f_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-rcurl-1.98_1.2-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-limma-3.42.0-r36h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-fastmatch-1.1_0-r36hcdcec82_1005[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing pthread-stubs-0.4-h14c3975_1001[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-gseabase-1.48.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-curl-4.3-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-ggplotify-0.0.5-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gxx_impl_linux-64-7.5.0-hdf63c60_6[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-shiny-1.5.0-r36h6115d3f_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-biocparallel-1.20.0-r36he1b5a44_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-htmltools-0.5.0-r36h0357c0b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-vctrs-0.3.2-r36hcdcec82_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libstdcxx-ng-9.3.0-hdf63c60_16[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing jpeg-9d-h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-urltools-1.7.3-r36h0357c0b_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-bh-1.72.0_3-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing certifi-2020.6.20-py38h32f6830_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-dyndoc-1.64.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-commonmark-1.7-r36hcdcec82_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-gosemsim-2.12.0-r36he1b5a44_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-rprojroot-1.3_2-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing cairo-1.16.0-h3fc0475_1005[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-mgcv-1.8_32-r36h7fa42b6_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing _r-mutex-1.0.1-anacondar_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing binutils_linux-64-2.34-hc952b39_20[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-yaml-2.2.1-r36hcdcec82_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-processx-3.4.3-r36hcdcec82_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-annotationforge-1.28.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-ps-1.3.4-r36hcdcec82_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-hms-0.5.3-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing libxcb-1.13-h14c3975_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-annotate-1.64.0-r36_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-gridextra-2.3-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-s4vectors-0.24.0-r36h516909a_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-plogr-0.2.0-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing fontconfig-2.13.1-h1056068_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-lambda.r-1.2.4-r36h6115d3f_1[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-pkgload-1.1.0-r36h0357c0b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-bitops-1.0_6-r36hcdcec82_1004[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-rematch-1.0.1-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-dplyr-1.0.2-r36h0357c0b_0[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing xorg-kbproto-1.0.7-h14c3975_1002[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-munsell-0.5.0-r36h6115d3f_1003[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-memoise-1.1.0-r36h6115d3f_1004[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-assertthat-0.2.1-r36h6115d3f_2[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing gcc_linux-64-7.5.0-hf34d7eb_27[0m
12:48:30 [32mBIOCONDA INFO[0m (OUT) removing r-readxl-1.3.1-r36hde08347_4[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-rcpparmadillo-0.9.900.2.0-r36h51c796c_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-bit-4.0.4-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing binutils_impl_linux-64-2.34-h53a641e_7[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-labeling-0.3-r36h6115d3f_1003[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-rlang-0.4.7-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-bit64-4.0.2-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-rdavidwebservice-1.24.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-igraph-1.2.5-r36hd626d4e_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-iranges-2.20.0-r36h516909a_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-cowplot-1.0.0-r36h6115d3f_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-mass-7.3_52-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-crayon-1.3.4-r36h6115d3f_1003[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-mfuzz-2.46.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing c-ares-1.16.1-h516909a_3[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-lattice-0.20_41-r36hcdcec82_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-askpass-1.1-r36hcdcec82_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-class-7.3_17-r36hcdcec82_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-mime-0.9-r36hcdcec82_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing gcc_impl_linux-64-7.5.0-hda68d29_13[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-shinythemes-1.1.2-r36h6115d3f_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-callr-3.4.3-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-praise-1.0.0-r36h6115d3f_1004[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-dbi-1.1.0-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-ggraph-2.0.3-r36h0357c0b_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-tweenr-1.0.1-r36h0357c0b_1002[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-rgraphviz-2.30.0-r36he1b5a44_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing fribidi-1.0.10-h516909a_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-do.db-2.9-r36_7[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bzip2-1.0.8-h516909a_3[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing graphite2-1.3.13-he1b5a44_1001[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-rcpp-1.0.5-r36h0357c0b_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-viridis-0.5.1-r36h6115d3f_1004[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-qvalue-2.18.0-r36_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing ld_impl_linux-64-2.34-h53a641e_7[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing glib-2.65.0-h6f030ca_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-gridgraphics-0.5_0-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-lifecycle-0.2.0-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-go.db-3.10.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-withr-2.2.0-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-xextproto-7.3.0-h14c3975_1002[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing gfortran_impl_linux-64-7.5.0-hdf63c60_6[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-viridislite-0.3.0-r36h6115d3f_1003[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-ggrepel-0.8.2-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-rcppeigen-0.3.3.7.0-r36h51c796c_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-europepmc-0.4-r36h6115d3f_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-later-1.1.0.1-r36h0357c0b_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-r6-2.4.1-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-fgsea-1.12.0-r36he1b5a44_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-gostats-2.52.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-dose-3.12.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-tidyselect-1.1.0-r36h6115d3f_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing libblas-3.8.0-17_openblas[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-testthat-2.3.2-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-futile.options-1.0.1-r36h6115d3f_1002[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-renderproto-0.11.1-h14c3975_1002[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing pixman-0.38.0-h516909a_1003[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-matrixstats-0.56.0-r36hcdcec82_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-formatr-1.7-r36h6115d3f_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-libsm-1.2.3-h84519dc_1000[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-cli-2.0.2-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-survival-3.2_3-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing libuuid-2.32.1-h14c3975_1000[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing gfortran_linux-64-7.5.0-h09487f9_20[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing libtiff-4.1.0-hc7e4089_6[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-rcolorbrewer-1.1_2-r36h6115d3f_1003[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-blob-1.2.1-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-ellipsis-0.3.1-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-fastmap-1.0.1-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-libxau-1.0.9-h14c3975_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-reshape2-1.4.4-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-rsqlite-2.2.0-r36h0357c0b_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-xproto-7.0.31-h14c3975_1007[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-backports-1.1.9-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-widgettools-1.64.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-enrichplot-1.6.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-httpuv-1.5.4-r36h0357c0b_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing tk-8.6.10-hed695b0_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bwidget-1.9.14-0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-openssl-1.4.2-r36he5c4762_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-base64enc-0.1_3-r36hcdcec82_1004[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-tidyr-1.1.1-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing freetype-2.10.2-he06d7ca_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing setuptools-49.6.0-py38h32f6830_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-utf8-1.1.4-r36hcdcec82_1003[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-rbgl-1.62.1-r36he1b5a44_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-genefilter-1.68.0-r36hc99cbb1_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-graphlayouts-0.7.0-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-colorspace-1.4_1-r36hcdcec82_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-biocmanager-1.30.10-r36h6115d3f_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing pango-1.42.4-h7062337_4[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-sys-3.4-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-plyr-1.8.6-r36h0357c0b_1[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing gxx_impl_linux-64-7.5.0-h64c220c_13[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-libice-1.0.10-h516909a_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing libgcc-ng-9.3.0-h24d8f2e_16[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-sourcetools-0.1.7-r36he1b5a44_1002[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing sed-4.8-hbfbb72e_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing gxx_linux-64-7.5.0-ha781d05_27[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-graph-1.64.0-r36h516909a_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-promises-1.1.1-r36h0357c0b_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-libx11-1.6.11-h516909a_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing xorg-libxrender-0.9.10-h516909a_1002[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-evaluate-0.14-r36h6115d3f_2[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing liblapack-3.8.0-17_openblas[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-category-2.52.0-r36_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing bioconductor-biobase-2.46.0-r36h516909a_0[0m
12:48:31 [32mBIOCONDA INFO[0m (OUT) removing r-glue-1.4.1-r36hcdcec82_0[0m
12:48:31 [32mBIOCONDA INFO[0m CLEANED UP PACKAGE CACHE (free space: 979MB).[0m
12:48:31 [31mBIOCONDA ERROR[0m BUILD SUMMARY: of 1 recipes, 1 failed and 0 were skipped. Details of recipes and environments follow.[0m
12:48:31 [31mBIOCONDA ERROR[0m BUILD SUMMARY: FAILED recipe recipes/vsclust[0m
[31mError: 
Exited with code exit status 1
[0m
[31mStep failed[0m
Error: runner failed (exited with 101)
[31mTask failed[0m
Error: task failed
