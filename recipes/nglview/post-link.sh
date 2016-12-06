#!/bin/sh

"${PREFIX}/bin/jupyter-nbextension" install nglview --py --user
"${PREFIX}/bin/jupyter-nbextension" enable nglview --py --user
