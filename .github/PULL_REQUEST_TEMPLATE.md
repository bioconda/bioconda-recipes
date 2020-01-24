**Replace this sentence with a detailed description of your pull request**

----

> Bioconda requires reviews prior to merging pull-requests (PRs). To facilitate this, once your PR is passing tests and ready to be merged, please add the `please review & merge` label so other members of the bioconda community can have a look at your PR and either make suggestions or merge it.

* [ ] I have read the [guidelines for bioconda recipes](https://bioconda.github.io/contributor/guidelines.html).
* [ ] This PR adds a new recipe.
* [ ] AFAIK, this recipe **is directly relevant to the biological sciences**
      (otherwise, please submit to the more general purpose [conda-forge channel](https://conda-forge.org/docs/)).
* [ ] This PR updates an existing recipe.
* [ ] This PR does something else (explain below).

> Everyone has access to the following BiocondaBot commands, which can be given in a comment:
>
>  * `@BiocondaBot please update` will cause the BiocondaBot to merge the master branch into a PR
>  * `@BiocondaBot please add label` will add the `please review & merge` label.
>  * `@BiocondaBot please fetch artifacts` will post links to packages and docker containers built by the CI system. You can use this to test packages locally before merging.
>
> For members of the Bioconda project, the following command is also available:
>
>  * `@BiocondaBot please merge` will cause packages/containers to be uploaded and a PR merged. Someone must approve a PR first! This has the benefit of not wasting CI build time required by manually merging PRs.
>
> If you have questions, please post them in gitter or ping `@bioconda/core` in a comment (if you are not able to directly ping `@bioconda/core` then the bot will repost your comment and enable pinging).
