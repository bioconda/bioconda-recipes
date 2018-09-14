FROM condaforge/linux-anvil
RUN sudo -n yum install -y openssh-clients
RUN mkdir -p /tmp/repo/bioconda_utils/
COPY ./bioconda_utils/bioconda_utils-requirements.txt /tmp/repo/bioconda_utils/
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install --file /tmp/repo/bioconda_utils/bioconda_utils-requirements.txt && \
    conda clean -y --all
COPY . /tmp/repo
RUN export PATH="/opt/conda/bin:${PATH}" && \
    pip install /tmp/repo
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/tmp/repo/docker-entrypoint" ]
