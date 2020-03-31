#!/usr/bin/env bash

set -ex
IMAGE=$1

##
# Step 1: Generate new version
##
previous_version=$(semversioner current-version)
semversioner release
new_version=$(semversioner current-version)

##
# Step 2: Generate CHANGELOG.md
##
echo "Generating CHANGELOG.md file..."
semversioner changelog > CHANGELOG.md
# Use new version in the README.md examples
echo "Replace version '$previous_version' to '$new_version' in README.md ..."
sed -i "s/$BITBUCKET_REPO_SLUG:[0-9]*\.[0-9]*\.[0-9]*/$BITBUCKET_REPO_SLUG:$new_version/g" README.md
# Use new version in the pipe.yml metadata file
echo "Replace version '$previous_version' to '$new_version' in pipe.yml ..."
sed -i "s/$BITBUCKET_REPO_SLUG:[0-9]*\.[0-9]*\.[0-9]*/$BITBUCKET_REPO_SLUG:$new_version/g" pipe.yml

##
# Step 3: Build and push docker image
##
echo "Build and push docker image..."
echo ${DOCKERHUB_PASSWORD} | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
docker build -t ${IMAGE} .
docker tag ${IMAGE} ${IMAGE}:${new_version}
docker push ${IMAGE}

##
# Step 4: Setup SSH access for commiting to repository
##
echo "Setting up ssh keys for em-bitbucket-bot..."
(mkdir -p ~/.ssh ; umask  077 ; echo ${SSH_KEY_BASE64} | base64 --decode > ~/.ssh/id_rsa)

##
# Step 5: Commit back to the repository
##
echo "Committing updated files to the repository..."
git add .
git commit -m "Update files for new version '${new_version}' [skip ci]"
git push origin ${BITBUCKET_BRANCH}

##
# Step 6: Tag the repository
##
echo "Tagging for release ${new_version}" "${new_version}"
git tag -a -m "Tagging for release ${new_version}" "${new_version}"
git push origin ${new_version}