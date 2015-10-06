FROM centos:centos5
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
RUN yum install -y wget bzip2 bzip2-devel git gcc gcc-c++ patch zlib-devel make gcc44 gcc44-c++ cmake ncurses-devel
RUN wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
RUN yum install -y devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++
RUN mkdir -p /tmp/conda-build
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash Miniconda3-latest-Linux-x86_64.sh -b -p /tmp/conda-build/anaconda
ENV PATH=/tmp/conda-build/anaconda/bin:$PATH
RUN mkdir -p /tmp/conda-build/anaconda/conda-bld/linux-64 # workaround for bug in current conda
RUN conda install -y conda conda-build anaconda-client pyyaml toolz jinja2
RUN conda config --add channels bioconda
ADD ../scripts/build-packages.sh /bin/build-packages.sh
