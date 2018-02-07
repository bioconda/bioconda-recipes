FROM condaforge/linux-anvil
RUN sudo -n yum install -y openssh-clients
COPY . /tmp/repo
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda config --add channels defaults && \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install --file /tmp/repo/bioconda_utils/bioconda_utils-requirements.txt && \
    conda clean -y --all
RUN export PATH="/opt/conda/bin:${PATH}" && \
    pip install /tmp/repo
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/tmp/repo/docker-entrypoint" ]
