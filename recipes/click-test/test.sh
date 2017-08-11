#!/bin/bash
export LC_ALL="C.UTF-8"
export LANG="C.UTF-8"
ENCODING=$(python -c 'import locale, codecs; print(codecs.lookup(locale.getpreferredencoding()).name)')
[[ ENCODING -eq "utf-8" ]]
