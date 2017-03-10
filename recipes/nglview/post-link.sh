#!/bin/sh

"${PREFIX}/bin/jupyter-nbextension" install nglview --py --sys-prefix || exit 0
"${PREFIX}/bin/jupyter-nbextension" enable nglview --py --sys-prefix || exit 0
