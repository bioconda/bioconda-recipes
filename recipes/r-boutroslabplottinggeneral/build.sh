# R 4.5 no longer exposes legacy Calloc/Free in this compilation mode.
# Adapt upstream C code to current R memory APIs before build.
perl -0pi -e 's/#include <Rinternals.h>\n/#include <Rinternals.h>\n#include <R_ext\/Memory.h>\n/' src/ks.c
perl -pi -e 's/\bCalloc\b/R_Calloc/g; s/\bFree\b/R_Free/g' src/ks.c

$R CMD INSTALL --build .
