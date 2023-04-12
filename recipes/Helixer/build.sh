!/bin/bash

cd Helixer
pip install .
git clone https://github.com/TonyBolger/HelixerPost.git
cd HelixerPost && cargo build --release

#cp helixer_post_bin ~/miniconda3/envs/helixer_environement/bin/helixer_post_bin #
p=`pwd`
export PATH=$PATH:/$p/helixer_post_bin
#export PATH="$p/helixer_post_bin:$PATH" 
echo $PATH