
### Get the code
First, download and checkout the latest release
```shell script
# from a directory of your choice
git clone https://github.com/weberlab-hhu/Helixer.git
cd Helixer
# git checkout dev # v0.2.0
```

### System dependencies

#### Python 3.8 or later

#### Python development libraries
Ubuntu (& co.)
```shell script
sudo apt install python3-dev
```
Fedora (& co.)
```shell script
sudo dnf install python3-devel
```

### Virtualenv (optional)
We recommend installing all the python packages in a
virtual environment: https://docs.python-guide.org/dev/virtualenvs/

For example, create and activate an environment called 'env': 
```shell script
python3 -m venv env
source env/bin/activate
```
The steps below assume you are working in the same environment.

### GPU requirements (optional, but highly recommended for realistically sized datasets)
And to run on a GPU (highly recommended for realistically sized datasets),
everything for tensorflow-gpu is required, 
see: https://www.tensorflow.org/install/gpu


The following has been most recently tested.

python packages:
* tensorflow-gpu==2.7.0

system packages:
* cuda-11-2
* libcudnn8
* libcudnn8-dev
* nvidia-driver-495

A GPU with 11GB Memory (e.g. GTX 1080 Ti) can run the largest 
configurations described below, for smaller GPUs you might
have to reduce the network or batch size.

### Post processor

https://github.com/TonyBolger/HelixerPost

Setup according to included instructions and
further add the compiled `helixer_post_bin` to 
your system PATH. 

### Most python dependencies of Helixer
```shell script
# from the Helixer directory
pip install -r requirements.txt
```

### Helixer itself

```shell script
# from the Helixer directory
pip install .  # or `pip install -e .`, if you will be changing the code
```
