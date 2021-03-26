FROM quay.io/condaforge/linux-anvil-cos7-x86_64 as base

# Copy over C.UTF-8 locale from our base image to make it consistently available during build.
COPY --from=quay.io/bioconda/base-glibc-busybox-bash /usr/lib/locale/C.UTF-8 /usr/lib/locale/C.UTF-8

# Provide system deps unconditionally until we are able to offer per-recipe installs.
# (Addresses, e.g., "ImportError: libGL.so.1" in tests directly invoked by conda-build.)
# Also install packages that have been installed historically (openssh-client).
RUN yum install -y mesa-libGL-devel \
    && \
    yum install -y openssh-clients \
    && \
    yum clean all && \
    rm -rf /var/cache/yum/*

# This changes root's .condarc which ENTRYPOINT copies to /home/conda/.condarc later.
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda config \
      --prepend channels defaults \
      --prepend channels bioconda \
      --prepend channels conda-forge \
    && \
    { conda config --remove repodata_fns current_repodata.json 2> /dev/null || true ; } && \
    conda config --prepend repodata_fns repodata.json && \
    conda config --set auto_update_conda False

FROM base as build
WORKDIR /tmp/repo
COPY . ./
RUN . /opt/conda/etc/profile.d/conda.sh  && conda activate base && \
    pip wheel . && \
    mkdir - /opt/bioconda-utils && \
    cp ./bioconda_utils-*.whl \
        ./bioconda_utils/bioconda_utils-requirements.txt \
        /opt/bioconda-utils/ \
    && \
    chgrp -R lucky /opt/bioconda-utils && \
    chmod -R g=u /opt/bioconda-utils

FROM base
COPY --from=build /opt/bioconda-utils /opt/bioconda-utils
RUN . /opt/conda/etc/profile.d/conda.sh  && conda activate base && \
    # Make sure we get the (working) conda we want before installing the rest.
    sed -nE \
        '/^conda([><!=~ ].+)?$/p' \
        /opt/bioconda-utils/bioconda_utils-requirements.txt \
        | xargs -r conda install --yes && \
    conda install --yes --file /opt/bioconda-utils/bioconda_utils-requirements.txt && \
    pip install --no-deps --find-links /opt/bioconda-utils bioconda_utils && \
    conda clean --yes --index --tarballs && \
    # Find files that are not already in group "lucky" and change their group and mode.
    find /opt/conda \
      \! -group lucky \
      -exec chgrp --no-dereference lucky {} + \
      \! -type l \
      -exec chmod g=u {} +
