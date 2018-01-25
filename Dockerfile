FROM condaforge/linux-anvil
ENV PATH="/opt/conda/bin:${PATH}"
RUN sudo -n yum install -y openssh-clients
ADD . /tmp/repo
RUN conda config --add channels defaults; \
    conda config --add channels conda-forge; \
    conda config --add channels bioconda
RUN conda install --file /tmp/repo/bioconda_utils/bioconda_utils-requirements.txt; \
    conda clean -y --all
RUN pip install /tmp/repo
