#!/bin/sh

"${PREFIX}/bin/jupyter-nbextension" install nglview --py --sys-prefix
"${PREFIX}/bin/jupyter-nbextension" enable nglview --py --sys-prefix
