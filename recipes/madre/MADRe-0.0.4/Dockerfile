FROM continuumio/miniconda3

COPY . /madre
WORKDIR /madre

RUN conda update -n base -c defaults conda && \
    conda create -y -n madre_env python=3.10 pip && \
    /bin/bash -c "source activate madre_env && \
    conda install -y -c bioconda -c conda-forge \
        scikit-learn minimap2 flye metamdbg hairsplitter seqkit && \
    pip install ."

SHELL ["/bin/bash", "-c"]
ENV PATH /opt/conda/envs/madre_env/bin:$PATH
ENV CONDA_DEFAULT_ENV madre_env

ENTRYPOINT ["madre"]
