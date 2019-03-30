"""
Access to configuration, hardcoded and from environ
"""

import os
import re

def get_secret(name):
    try:
        with open(os.environ[name + "_FILE"]) as secret_file:
            return secret_file.read()
    except (FileNotFoundError, PermissionError, KeyError):
        try:
            return os.environ[name]
        except KeyError:
            raise ValueError(
                f"Missing secrets: configure {name} or {name}_FILE to contain or point at secret"
            ) from None

#: PEM signing key for APP requests
APP_KEY = get_secret("APP_KEY")

#: Numeric App ID (not secret, technically)
APP_ID = get_secret("APP_ID")

#: Secret shared with Github used by us to authenticate incoming webhooks
APP_SECRET = get_secret("APP_SECRET")

#: GPG key for signing git commits
CODE_SIGNING_KEY = get_secret("CODE_SIGNING_KEY")

#: Name of bot
BOT_NAME = "BiocondaBot"

#: Bot alias regex - this is what it'll react to in comments
BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)

#: Email address used in commits. Needs to match the account under
#: which the CODE_SIGNING_KEY was registered.
BOT_EMAIL = "47040946+BiocondaBot@users.noreply.github.com"
