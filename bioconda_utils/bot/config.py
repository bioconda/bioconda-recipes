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

APP_KEY = get_secret("APP_KEY")
APP_ID = get_secret("APP_ID")
CODE_SIGNING_KEY = get_secret("CODE_SIGNING_KEY")

BOT_NAME = "BiocondaBot"
BOT_ALIAS_RE = re.compile(r'@bioconda[- ]?bot', re.IGNORECASE)
BOT_EMAIL = "47040946+BiocondaBot@users.noreply.github.com"
