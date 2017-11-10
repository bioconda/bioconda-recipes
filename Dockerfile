FROM condaforge/linux-anvil
RUN /usr/bin/sudo -n yum install -y openssh-clients
COPY bioconda_utils/bioconda_utils-requirements.txt /tmp/requirements.txt
COPY setup-channels.sh /tmp/setup-channels.sh
RUN CONDA_ROOT=/opt/conda bash tmp/setup-channels.sh
RUN /opt/conda/bin/conda install --file /tmp/requirements.txt
