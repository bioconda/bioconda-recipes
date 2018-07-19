import os

import github


def _n(x):
    """
    Easy conversion of None to NotSet object used by PyGithub; otherwise pass
    through unchanged.
    """
    if x is None:
        return github.GithubObject.NotSet
    return x


def push_comment(user, repo, pull_request_number, msg):
    """
    Expects GITHUB_TOKEN to exist as an env var, and uses it to authenticate.

    user : str

    repo : str

    pull_request_number : int

    msg : Markdown-formatted message
    """

    if 'GITHUB_TOKEN' not in os.environ:
        raise ValueError("GITHUB_TOKEN not defined as an env var")

    g = github.Github(os.environ['GITHUB_TOKEN'])
    user = g.get_user(user)
    repo = user.get_repo(repo)
    pr = repo.get_pull(pull_request_number)

    return pr.create_issue_comment(msg)


def update_status(user, repo, commit, state, context=None, description=None,
                  target_url=None):
    """
    Expects GITHUB_TOKEN to exist as an env var, and uses it to authenticate.

    user : str

    repo : str

    commit : str
        Full hash of the commit

    state :  pending | success | error | failure

    context : str
        Arbitrary, but multiple calls with different states but the same
        context will update the same context.

    description : str
        Optional description

    target_url : str
        Optional url with more info

    """
    if 'GITHUB_TOKEN' not in os.environ:
        raise ValueError("GITHUB_TOKEN not defined as an env var")

    g = github.Github(os.environ['GITHUB_TOKEN'])
    user = g.get_user(user)
    repo = user.get_repo(repo)
    commit = repo.get_commit(commit)

    return commit.create_status(
        state=state,
        context=_n(context),
        description=_n(description),
        target_url=_n(target_url))


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('commit')
    ap.add_argument('--state')
    ap.add_argument('--context')
    ap.add_argument('--description')
    args = ap.parse_args()
    status = update_status(
        'bioconda', 'bioconda-recipes', args.commit, args.state, args.context, args.description,
    )
    print(status)
