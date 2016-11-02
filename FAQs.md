# FAQs



## How do I get set up to test recipes locally?

### One-time setup

#### Install prerequisites

- Install conda (use the Python 3 version).

- Install conda-build in the root environment.

- Install Docker (optional, but allows you to simulate most closely the Travis-CI tests).

- Identify the branch of bioconda-utils currently used. It is indicated in
`bioconda-recipes/.travis.yml` (look for the `BIOCONDA_UTILS_TAG` env var).
Export that as an environment variable:

```
export BIOCONDA_UTILS_TAG=<PASTE TAG HERE>
```

- Install that version of bioconda-utils:

```
pip install git+https://github.com/bioconda/bioconda-utils.git@BIOCONDA_UTILS_TAG
```


#### Git and GitHub setup

- Create a fork of bioconda-recipes on GitHub and clone it locally. Even if you
are a member of the bioconda team with push access, this will allow testing of
your recipes on travis-ci without consuming resources allocated by travis-ci to
the `bioconda` group:

```
git clone https://github.com/<USERNAME>/bioconda-recipes.git
```

- Add the main bioconda-recipes repo as an upstream remote:

```
git remote add upstream https://github.com/bioconda/bioconda-recipes.git
```

- Connect the fork to travis-ci, following steps 1 and 2 from the [travis-ci
docs](https://docs.travis-ci.com/user/getting-started/#To-get-started-with-Travis-CI%3A)


### Write a recipe

Check out a new branch (e.g., `git checkout -b my-recipe`) and write one or
more recipes.

See the [conda docs](http://conda.pydata.org/docs/building/recipe.html) for
writing recipes, and see `GUIDELINES.md` in the bioconda-recipes repo for more
info.

### Test locally
The `simulate-travis.py` script reads the config files in the repo and sets
things up as closely as possible to how the builds will be run on travis-ci. It
should be run in the top-level dir of the repo. Any arguments are passed on to
the `bioconda-utils build` command, so check `bioconda-utils build -h` for help
and more options.

Some example commands:

This tests everything, using the installed conda-build. It will check all
recipes to see what needs to be built and so it is the most comprehensive:

```
./simulate-travis.py
```

Same thing but using `--docker`. If you're on OSX and have docker installed,
you can use this to test the recipe under Linux:

```
./simulate-travis.py --docker
```

Use the `--quick` option which will just check recipes that have changed since
the last commit to master branch or that have been newly removed from any
configured blacklists:

```
./simulate-travis.py --docker --quick
```

Or specify exactly which packages you want to try building. Note that the
arguments to `--package` can be globs and are of package *names* rather than
*paths* to recipe directories. For example, to consider all R and Bioconductor
packages:

```
./simulate-travis.py --docker --package r-* bioconductor-*
```


### Push to fork, wait for Travis-CI, submit pull request.

Push your changes to your fork on github, and watch the Travis-CI logs. Keep
making changes on your fork and pushing them until the travis-ci builds pass.

Open a [pull request](https://help.github.com/articles/about-pull-requests/) on
the bioconda-recipes repo. If it's your first recipe or the recipe is doing
something non-standard, please ask `@bioconda/core` for a review.

### Use your new recipe

When the PR is merged with the master branch, travis-ci will again do the
builds but at the end will upload the packages to anaconda.org. Once the merge
build completes, your new package is installable by anyone using:

```
conda install my-package-name -c bioconda
```


## How is Travis-CI set up and configured?

- `.travis.yml` is read by the Travis-CI worker.

- the worker runs `scripts/travis-setup.sh`, which installs conda, adds channels, and installs `bioconda-utils`

- the worker runs `scripts/travis-run.sh`. If the system is Linux, then the
build is performed in a docker container (the one listed in `.travis.yml`). If
OSX, then the build is performed without docker.

- Only if the build is on the master branch will it be uploaded to anaconda.org
## What does "SUBDAG" mean on Travis-CI?

We have limited resources on Travis-CI on which to build packages. In an
attempt to speed up builds, we split the full DAG of recipes that need to be
built in to multiple independent sub-DAGs. These are named `SUBDAG 0` and
`SUBDAG 1`. Each sub-DAG is considered an independent build and they are built
in parallel. If you submit a single recipe, which sub-DAG it is built on is
nondeterministic so if you don't see log output for the recipe in one sub-DAG,
check the other.

## How are environmental variables defined and used?

It is possible to use jinja2 templating in recipes to use a uniform set of
versions for core packages used by bioconda packages, for example see [this
`meta.yaml`](https://github.com/bioconda/bioconda-recipes/blob/f5eb63e30a76fd13c28663786d219c9f7750267c/recipes/gfold/meta.yaml).

This works by the following:

- [`config.yml` indicates an
`env_matrix`](https://github.com/bioconda/bioconda-recipes/blob/0be2881ef95be68feb09fae7814e0217aca57285/config.yml#L1)
in which CONDA_GSL is defined

- when figuring out which recipes need to be built, the filtering step attaches
each [unique env to a Target
object](https://github.com/bioconda/bioconda-utils/blob/63aacdedf583b6cda770c84f241120d48dfb77f5/bioconda_utils/utils.py#L511)
(e.g., `CONDA_GSL=1.6; CONDA_PY=27, CONDA_R=3.3.1;` etc}
- that [env is provided to the build
function](https://github.com/bioconda/bioconda-utils/blob/63aacdedf583b6cda770c84f241120d48dfb77f5/bioconda_utils/build.py#L312)
which is either
  - sent [directly to
  docker](https://github.com/bioconda/bioconda-utils/blob/63aacdedf583b6cda770c84f241120d48dfb77f5/bioconda_utils/build.py#L81)
  - or used to [temporarily update
  os.environ](https://github.com/bioconda/bioconda-utils/blob/63aacdedf583b6cda770c84f241120d48dfb77f5/bioconda_utils/build.py#L94)
  so that conda-build sees it.
- These environmental variables are then [used over in
conda-build](https://github.com/conda/conda-build/blob/9ace97969e77a10afc3c03022f8a1d0f47c2a043/conda_build/jinja_context.py#L205)
to fill in the templated variables via jinja2.
