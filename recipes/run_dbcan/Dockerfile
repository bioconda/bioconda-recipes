FROM ubuntu:16.04

# Use the mirror of ubuntu rather than the default
RUN rm -rf /etc/apt/sources.list
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
# RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
# RUN echo "deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
# RUN echo "deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
# RUN echo "deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list
# RUN echo "deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list

# Install some basic utilities
RUN apt-get clean && apt-get -o Acquire::http::No-Cache=True update --fix-missing && apt-get install -y \
    make \
    sudo \
    gcc \
    g++ \
    git \
    wget \
    curl \
    bzip2 \
    libx11-6 \
    hmmer \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
  && chown -R user:user /app
RUN echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-user
USER user

# Set home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.5.1-Linux-x86_64.sh \
  && chmod +x ~/miniconda.sh \
  && ~/miniconda.sh -b -p ~/miniconda \
  && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a python 3.6 environment
RUN /home/user/miniconda/bin/conda install conda-build \
  && /home/user/miniconda/bin/conda create -y --name py36 python=3.6.5 \
  && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/${CONDA_DEFAULT_ENV}
ENV PATH=${CONDA_PREFIX}/bin:${PATH}

# Install Python Modules
# RUN conda install -y natsort \
#   && conda clean -ya
RUN pip install natsort \
  argparse

# Create diamond environment
RUN mkdir ~/Diamond && wget http://github.com/bbuchfink/diamond/releases/download/v0.9.24/diamond-linux64.tar.gz -P ~/Diamond \
  && tar -xzvf ~/Diamond/diamond-linux64.tar.gz -C ~/Diamond && chmod +x ~/Diamond/diamond && rm ~/Diamond/diamond-linux64.tar.gz
ENV PATH=/home/user/Diamond:${PATH}

# Create Prodigal environment
RUN mkdir ~/prodigal && git clone https://github.com/hyattpd/Prodigal.git ~/prodigal \
  && cd ~/prodigal && sudo make install \
  && rm -r ~/prodigal

# Create fraggenescan environment
RUN wget https://downloads.sourceforge.net/project/fraggenescan/FragGeneScan1.31.tar.gz -P ~ \
  && tar -xzvf ~/FragGeneScan1.31.tar.gz -C ~ && cd ~/FragGeneScan1.31 \
  && make && make clean && make fgs \
  && rm ~/FragGeneScan1.31.tar.gz
ENV PATH=/home/user/FragGeneScan1.31:${PATH}

# Download run_dbcan2, you need to download signalP by yourself because of signalP license.
RUN git clone https://github.com/linnabrown/run_dbcan.git /app 
#   && cd /app/tools/ && tar -xzvf signalp-4.1.tar.gz \
#   && chmod +x /app/tools/signalp-4.1/signalp \
#   && rm /app/tools/signalp-4.1.tar.gz
# ENV PATH=/app/tools/signalp-4.1:${PATH}

# Download and make the database for run_dbcan
RUN mkdir /app/db && cd /app/db \
  && wget http://bcb.unl.edu/dbCAN2/download/Databases/CAZyDB.07312018.fa && diamond makedb --in CAZyDB.07312018.fa -d CAZy \
  && wget http://bcb.unl.edu/dbCAN2/download/Databases/dbCAN-HMMdb-V7.txt && mv dbCAN-HMMdb-V7.txt dbCAN.txt && hmmpress dbCAN.txt \
  && wget http://bcb.unl.edu/dbCAN2/download/Databases/tcdb.fa && diamond makedb --in tcdb.fa -d tcdb \
  && wget http://bcb.unl.edu/dbCAN2/download/Databases/tf-1.hmm && hmmpress tf-1.hmm \
  && wget http://bcb.unl.edu/dbCAN2/download/Databases/tf-2.hmm && hmmpress tf-2.hmm \
  && wget http://bcb.unl.edu/dbCAN2/download/Databases/stp.hmm && hmmpress stp.hmm

CMD [ "python3 /app/run_dbcan.py" ]