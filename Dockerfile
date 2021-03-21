FROM condaforge/linux-anvil-comp7 as base
# Pretend we'd have C.UTF-8: Just copy en_US.UTF-8
RUN localedef -i en_US -f UTF-8 C.UTF-8
RUN sudo -n yum install -y openssh-clients && \
    sudo -n yum clean all && \
    sudo -n rm -rf /var/cache/yum/*
ENV PATH="/opt/conda/bin:${PATH}"
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    { conda config --remove repodata_fns current_repodata.json || true ; } && \
    conda config --prepend repodata_fns repodata.json && \
    conda config --set auto_update_conda False

FROM base as build
WORKDIR /tmp/repo
COPY . ./
RUN pip wheel . && \
    mkdir - /opt/bioconda-utils && \
    cp ./bioconda_utils-*.whl \
        ./bioconda_utils/bioconda_utils-requirements.txt \
        ./docker-entrypoint* \
        /opt/bioconda-utils/

FROM base
COPY --from=build /opt/bioconda-utils /opt/bioconda-utils
RUN \
    # Make sure we get the (working) conda we want before installing the rest.
    sed -nE \
        -e 's/\s*#.*$//' \
        -e 's/^(conda([><!=~ ].+)?)$/\1/p' \
        /opt/bioconda-utils/bioconda_utils-requirements.txt \
        | xargs -r conda install -y && \
    conda install -y --file /opt/bioconda-utils/bioconda_utils-requirements.txt && \
    pip install --no-deps -f /opt/bioconda-utils bioconda_utils && \
    conda clean -y -it

ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/bioconda-utils/docker-entrypoint" ]
