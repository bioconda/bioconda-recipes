#!/bin/sh
  
# Unset the passed env var <myvar>, backing up its value in BAK_<myvar>.
backup_env_var() {
    local var_name
    var_name="$1"

    # Var defined and value given, or defined and NO value given
    if [ -n "${!var_name}" ] || [ -z "${!var_name-foo}" ]; then
        export BAK_$var_name="${!var_name}"
        unset $var_name
    fi
}

backup_env_var PATH

export IRAP_DIR="$CONDA_PREFIX/bin/irap"
export PATH="$CONDA_PREFIX/bin/irap:$CONDA_PREFIX/bin/irap/scripts:$BAK_PATH"
