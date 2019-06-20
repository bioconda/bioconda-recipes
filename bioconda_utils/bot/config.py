"""
Bot configuration variables
"""

import os
import re
import sys

def get_secret(name):
    """Load a secret from file or env

    Either provide ``{name}_FILE`` or ``{name}`` in the environment to
    configure the value for ``{name}``.
    """
    try:
        with open(os.environ[name + "_FILE"]) as secret_file:
            return secret_file.read().strip()
    except (FileNotFoundError, PermissionError, KeyError):
        try:
            return os.environ[name]
        except KeyError:
            if os.path.basename(sys.argv[0]) == 'sphinx-build':
                # We won't have nor need secrets when building docs
                return None
            raise ValueError(
                f"Missing secrets: configure {name} or {name}_FILE to contain or point at secret"
            ) from None

#: PEM signing key for APP requests
APP_KEY = get_secret("APP_KEY")

#: Numeric App ID (not secret, technically)
APP_ID = get_secret("APP_ID")

#: App OAuth client ID
APP_CLIENT_ID = get_secret("APP_CLIENT_ID")

#: App OAuth client secret
APP_CLIENT_SECRET = get_secret("APP_CLIENT_SECRET")

#: Secret shared with Github used by us to authenticate incoming webhooks
APP_SECRET = get_secret("APP_SECRET")

#: GPG key for signing git commits
CODE_SIGNING_KEY = get_secret("CODE_SIGNING_KEY")

#: CircleCI Token
CIRCLE_TOKEN = get_secret("CIRCLE_TOKEN")

#: Quay Login
QUAY_LOGIN = get_secret("QUAY_LOGIN")

#: Anaconda Token
ANACONDA_TOKEN = get_secret("ANACONDA_TOKEN")

#: Gitter Token
GITTER_TOKEN = get_secret("GITTER_TOKEN")

#: Gitter Channels
GITTER_CHANNELS = {
    'bioconda/Lobby': 'bioconda/bioconda-recipes',
    'bioconda/bot': 'bioconda/bioconda-recipes'
}
#GITTER_CHANNELS = {
#    'bioconda/bot_test': 'epruesse/bioconda-recipes'
#}

#: Name of bot
BOT_NAME = "BiocondaBot"

#: Bot alias regex - this is what it'll react to in comments
BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)

#: Email address used in commits. Needs to match the account under
#: which the CODE_SIGNING_KEY was registered.
BOT_EMAIL = "47040946+BiocondaBot@users.noreply.github.com"

#: Time in seconds after which repodata should be reloaded
REPODATA_TIMEOUT = 300

#: Assign PRs to project columns by label
PROJECT_COLUMN_LABEL_MAP = {
     5706816: set(('please review & merge',)),
}
