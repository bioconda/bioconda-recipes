#!/usr/bin/env bash

# Install the CircleCI CLI tool.
# https://github.com/CircleCI-Public/circleci-cli
#
# Dependencies: curl, cut
#
# The version to install and the binary location can be passed in via VERSION and DESTDIR respectively.
#

set -o errexit

echo "Starting installation."
DESTDIR="/data/mscholz_software/bin"

# GitHub's URL for the latest release, will redirect.
GITHUB_BASE_URL="https://github.com/CircleCI-Public/circleci-cli"
LATEST_URL="${GITHUB_BASE_URL}/releases/latest/"
DESTDIR="${DESTDIR:-/usr/local/bin}"

if [ -z "$VERSION" ]; then
	VERSION=$(curl -sLI -o /dev/null -w '%{url_effective}' "$LATEST_URL" | cut -d "v" -f 2)
fi

echo "Installing CircleCI CLI v${VERSION}"

# Run the script in a temporary directory that we know is empty.
SCRATCH=$(mktemp -d || mktemp -d -t 'tmp')
cd "$SCRATCH"

function error {
  echo "An error occured installing the tool."
  echo "The contents of the directory $SCRATCH have been left in place to help to debug the issue."
}

trap error ERR

# Determine release filename. This can be expanded with CPU arch in the future.
case "$(uname)" in
	Linux)
		OS='linux'
	;;
	Darwin)
		OS='darwin'
	;;
	*)
		echo "This operating system is not supported."
		exit 1	
	;;
esac

RELEASE_URL="${GITHUB_BASE_URL}/releases/download/v${VERSION}/circleci-cli_${VERSION}_${OS}_amd64.tar.gz"

# Download & unpack the release tarball.
curl -sL --retry 3 "${RELEASE_URL}" | tar zx --strip 1

echo "Installing to $DESTDIR"
install circleci "$DESTDIR"

command -v circleci

# Delete the working directory when the install was successful.
rm -r "$SCRATCH"
