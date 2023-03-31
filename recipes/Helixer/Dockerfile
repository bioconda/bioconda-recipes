FROM nvidia/cuda:11.2.0-cudnn8-runtime-ubuntu20.04 
RUN useradd --create-home --shell /bin/bash helixer_user
RUN apt-get update -y
RUN apt-get install python3-dev -y
RUN apt-get install python3-pip -y
RUN apt-get install python3-venv -y
RUN apt-get install git -y
RUN apt-get install libhdf5-dev -y
RUN apt-get install curl -y
RUN apt-get install libbz2-dev -y
RUN apt-get install liblzma-dev -y
RUN apt-get autoremove -y
RUN apt-get install -y wget


# --- install conda & prep for hdf5 and rustfor HelixerPost --- #
#FROM continuumio/miniconda3 
WORKDIR /tmp/
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
WORKDIR /app
RUN conda install h5py
RUN conda install rust

# --- Helixer and HelixerPost --- #

WORKDIR /home/helixer_user/
RUN git clone -b v0.3.1 https://github.com/weberlab-hhu/Helixer.git Helixer
RUN pip install --no-cache-dir -r /home/helixer_user/Helixer/requirements.txt
RUN cd Helixer && pip install --no-cache-dir .

WORKDIR /home/helixer_user/
RUN git clone https://github.com/TonyBolger/HelixerPost.git
RUN cd HelixerPost && git checkout 4d4799bac4c05e574ae628040c5cb58eb4aa18fe
RUN mkdir bin
ENV PATH="/home/helixer_user/bin:${PATH}"
RUN cd HelixerPost/helixer_post_bin && cargo build --release
RUN mv /home/helixer_user/HelixerPost/target/release/helixer_post_bin /home/helixer_user/bin/
RUN rm -r /home/helixer_user/HelixerPost/target/release/

USER helixer_user
CMD ["bash"]
