

While this recipe works without any known problems for a conda environment, we experienced issues using as a docker image. In this configuration, homer writes its DBs to:

$CONDA_PREFIX/share/homer/data for conda and this approach works.
/usr/local/share/homer/data for biocontainers, but this path is read-only. And as a result it is not possible to update / install new DBs to the container via configureHomer.pl (permission denied).


