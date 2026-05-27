# ScriptManager recipe for `bioconda`

```md
conda-recipe/
├── meta.yaml    # Package metadata, dependencies, source/docs URL
├── build.sh     # Linux / macOS install script
├── ~~bld.bat~~  # Windows install script (for if we submit to conda-forge)
└── README.md    # This file
```

## Adjusting default JVM memory

Edit the `JAVA_OPTS` default in `build.sh`:

```bash
JAVA_OPTS=${JAVA_OPTS:-"-Xmx4g"}
```

## Handy links

- Bioconda contribution guidelines: https://bioconda.github.io/contributor/index.html
- Bioconda linting rules: https://bioconda.github.io/contributor/linting.html
- conda-build `meta.yaml` docs: https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html
- Find example Java recipes in bioconda: `grep 'openjdk' bioconda-recipes/recipes/*/*.yaml |cut -d"/" -f 2 |sort |uniq`
- Bioconda publishing info: https://bioconda.github.io/contributor/workflow.html
- PR source fork: [owlang/bioconda-recipes](https://github.com/owlang/bioconda-recipes)
- source link (for convenience): [CEGRcode/scriptmanager](https://github.com/CEGRcode/scriptmanager)

## Test locally

```sh
# conda install conda-build # install if not already

# build the recipe (few minutes)
conda build bioconda-recipes/recipes/scriptmanager/

# install and test (few minutes)
conda install --use-local scriptmanager
scriptmanager --help
```
