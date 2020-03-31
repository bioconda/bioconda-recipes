**Describe your pull request here**

----

Please read the [guidelines for Bioconda recipes](https://bioconda.github.io/contributor/guidelines.html) before opening a pull request (PR).

* If this PR adds or updates a recipe, use "Add" or "Update" appropriately as the first word in its title.
* New recipes not directly relevant to the biological sciences need to be submitted to the [conda-forge channel](https://conda-forge.org/docs/) instead of Bioconda.
* PRs require reviews prior to being merged. Once your PR is passing tests and ready to be merged, please issue the `@BiocondaBot please add label` command.
* Please post questions [on Gitter](https://gitter.im/bioconda/Lobby) or ping `@bioconda/core` in a comment.

<details>
  <summary>Please make use of the following BiocondaBot commands whenever appropriate:</summary>

Everyone has access to the following BiocondaBot commands, which can be given in a comment:

  * `@BiocondaBot please update`
    <br/>causes the BiocondaBot to merge the master branch into a PR.
  * `@BiocondaBot please add label`
    <br/>adds the `please review & merge` label.
  * `@BiocondaBot please fetch artifacts`
    <br/>posts links to packages and docker containers built by the CI system.
    <br/>You can use this to test packages locally before merging.
  * Comments from non-members that include `@bioconda/<team>` will be automatically reposted to notify the addressed team.

For members of the Bioconda project, the following command is also available:

 * `@BiocondaBot please merge`
   <br/>uploads built packages/containers and merges a PR. Someone must approve a PR first!
   <br/>This has the benefit of not wasting CI build time required by manually merging PRs.
</details>
