#!/usr/bin/env bash
#
# Configure git to allow push back to the remote repository.
#
# Required globals:
#   PRIVATE_KEY: base64 encoded ssh private key
#

set -e

echo $PRIVATE_KEY > ~/.ssh/id_rsa.tmp
base64 -d ~/.ssh/id_rsa.tmp > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Configure git
git config user.name "Pipelines Tasks"
git config user.email commits-noreply@bitbucket.org
git remote set-url origin git@bitbucket.org:${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO_SLUG}.git