#!/bin/sh

# Restore the value of passed env var <myvar> from a backup variable
# BAK_<myvar> and unset the backup variable.
restore_env_var() {
    local var_name
    local bak_var_name
    var_name="${1}"
    bak_var_name="BAK_$var_name"

    # Var defined and value given, or defined and NO value given
    if [ -n "${!bak_var_name}" ] || [ -z "${!bak_var_name-foo}" ]; then
        export $var_name="${!bak_var_name}"
        unset $bak_var_name
    fi
}

restore_env_var PERL5LIB
# restore_env_var PERL_MM_OPT
# restore_env_var PERL_MB_OPT

