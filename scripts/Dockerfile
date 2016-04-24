FROM centos:centos5

# add tools useful for compilation
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
RUN yum install -y \
    wget bzip2 bzip2-devel git gcc gcc-c++ patch zlib-devel make gcc44 \
    gcc44-c++ cmake ncurses-devel unzip byacc && \
    yum clean all
RUN wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo && \
    wget --no-check-certificate https://copr.fedoraproject.org/coprs/praiskup/autotools/repo/epel-5/praiskup-autotools-epel-5.repo -O /etc/yum.repos.d/autotools.repo
RUN yum install -y \
    devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++ \
    devtoolset-2-gcc-gfortran autotools-latest pkgconfig which file gpg \
    # Needed for perl-db-file
    db4-devel \
    # install X11 dependencies and openGL/mesa
    xorg-x11-apps mesa-libGLU-devel \
    && yum clean all



# install conda
RUN mkdir -p /tmp/conda-build && wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash Miniconda3-latest-Linux-x86_64.sh -b -p /anaconda
ENV PATH=/opt/rh/devtoolset-2/root/usr/bin:/opt/rh/autotools-latest/root/usr/bin:/anaconda/bin:$PATH
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN mkdir -p /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64 # workaround for bug in current conda (conda issue #466)

# setup conda
ADD requirements.txt requirements.txt
RUN conda install -y --file requirements.txt
RUN conda index /anaconda/conda-bld/linux-64 /anaconda/conda-bld/osx-64
RUN conda config --add channels bioconda
RUN conda config --add channels r
RUN conda config --add channels file://anaconda/conda-bld
RUN conda install -y toposort

# setup entrypoint (assuming that repo is mounted under /bioconda-recipes)
ENTRYPOINT ["/bioconda-recipes/scripts/build-packages.py"]
CMD []
