Describe your pull request here

----

Please read the [guidelines for Bioconda recipes](https://bioconda.github.io/contributor/guidelines.html) before opening a pull request (PR).

### General instructions

* If this PR adds or updates a recipe, use "Add" or "Update" appropriately as the first word in its title.
* New recipes not directly relevant to the biological sciences need to be submitted to the [conda-forge channel](https://conda-forge.org/docs/) instead of Bioconda.
* PRs require reviews prior to being merged. Once your PR is passing tests and ready to be merged, please issue the `@BiocondaBot please add label` command.
* Please post questions [on Gitter](https://gitter.im/bioconda/Lobby) or ping `@bioconda/core` in a comment.

### Instructions for avoiding API, ABI, and CLI breakage issues
Conda is able to record and lock (a.k.a. pin) dependency versions used at build time of other recipes.
This way, one can avoid that expectations of a downstream recipe with regards to API, ABI, or CLI are violated by later changes in the recipe.
If not already present in the meta.yaml, make sure to specify `run_exports` (see [here](https://bioconda.github.io/contributor/linting.html#missing-run-exports) for the rationale and comprehensive explanation).
Add a `run_exports` section like this:

```yaml
build:
  run_exports:
    - ...

```

with `...` being one of:

| Case                             | run_exports statement                                               |
| -------------------------------- | ------------------------------------------------------------------- |
| semantic versioning              | `{{ pin_subpackage("myrecipe", max_pin="x") }}`     |
| semantic versioning (0.x.x)      | `{{ pin_subpackage("myrecipe", max_pin="x.x") }}`   |
| known breakage in minor versions | `{{ pin_subpackage("myrecipe", max_pin="x.x") }}` (in such a case, please add a note that shortly mentions your evidence for that) |
| known breakage in patch versions | `{{ pin_subpackage("myrecipe", max_pin="x.x.x") }}` (in such a case, please add a note that shortly mentions your evidence for that) |
| calendar versioning              | `{{ pin_subpackage("myrecipe", max_pin=None) }}`    |

while replacing `"myrecipe"` with either `name` if a `name|lower` variable is defined in your recipe or with the lowercase name of the package in quotes.

### Bot commands for PR management

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

Note that the <code>@BiocondaBot please merge</code> command is now depreciated. Please just squash and merge instead.

Also, the bot watches for comments from non-members that include `@bioconda/<team>` and will automatically re-post them to notify the addressed `<team>`.

</details>
