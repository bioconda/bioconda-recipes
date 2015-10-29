DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # directory of current script
source $DIR/etc/activate.d/*
export CONDA_ENV_PATH=$DIR
migmap -h
source $DIR/etc/deactivate.d/*
unset CONDA_ENV_PATH
