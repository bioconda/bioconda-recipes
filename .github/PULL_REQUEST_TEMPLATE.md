Describe your pull request here

----

Please read the [guidelines for Bioconda recipes](https://bioconda.github.io/contributor/guidelines.html) before opening a pull request (PR).

* If this PR adds or updates a recipe, use "Add" or "Update" appropriately as the first word in its title.
* New recipes not directly relevant to the biological sciences need to be submitted to the [conda-forge channel](https://conda-forge.org/docs/) instead of Bioconda.
* PRs require reviews prior to being merged. Once your PR is passing tests and ready to be merged, please issue the `@BiocondaBot please add label` command.
* Please post questions [on Gitter](https://gitter.im/bioconda/Lobby) or ping `@bioconda/core` in a comment.

<details>
  <summary>Please use the following BiocondaBot commands:</summary>

Everyone has access to the following BiocondaBot commands, which can be given in a comment:

<table>
  <tr>
    <td><code>@BiocondaBot please update</code></td>
    <td>Merge the master branch into a PR.</td>
  </tr>
  <tr>
    <td><code>@BiocondaBot please add label</code></td>
    <td>Add the <code>please review & merge</code> label.</td>
  </tr>
  <tr>
    <td><code>@BiocondaBot please fetch artifacts</code></td>
    <td>Post links to CI-built packages/containers. <br />You can use this to test packages locally.</td>
  </tr>
</table>

For members of the Bioconda project, the following command is also available:

<table>
  <tr>
    <td><code>@BiocondaBot please merge</code></td>
    <td>Upload built packages/containers and merge a PR. <br />Someone must approve a PR first! <br />This reduces CI build time by reusing built artifacts.</td>
  </tr>
</table>

Also, the bot watches for comments from non-members that include `@bioconda/<team>` and will automatically re-post them to notify the addressed `<team>`.

</details>
