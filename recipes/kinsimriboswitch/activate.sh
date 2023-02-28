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

backup_env_var PERL5LIB
# backup_env_var PERL_MM_OPT
# backup_env_var PERL_MB_OPT

export PERL5LIB="$PREFIX/lib/perl5_custom:$PERL5LIB"





# Set env vars, cf.
# https://conda.io/docs/user-guide/tasks/manage-environments.html#saving-environment-variables

