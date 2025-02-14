FROM ubuntu:22.04

# Use bash shell instead of sh
SHELL ["/bin/bash", "-c"]

# install git & wget
RUN apt-get update \
    && apt-get install -y \
    git \
    wget

# install conda
RUN mkdir -p /home/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/miniconda3/miniconda.sh
RUN bash /home/miniconda3/miniconda.sh -b -u -p /home/miniconda3
RUN rm /home/miniconda3/miniconda.sh
RUN echo 'export PATH=/home/miniconda3/bin:$PATH' >> ~/.bashrc
RUN source ~/.bashrc
