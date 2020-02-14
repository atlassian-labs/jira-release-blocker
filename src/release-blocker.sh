#!/usr/bin/env bash

source "$(dirname "$0")/common.sh"

#
# Required globals:
#   JIRA_JQL
#   JIRA_CLOUD_ID or JIRA_HOSTNAME
#   JIRA_USERNAME
#   JIRA_API_TOKEN
#
# Optional globals:
#   ALLOW_ROLLBACK_DEPLOYS (default: true)
#   DEBUG (default: false)

set -e

# required parameters
JIRA_USERNAME=${JIRA_USERNAME:?'JIRA_USERNAME environment variable missing'}
JIRA_API_TOKEN=${JIRA_API_TOKEN:?'JIRA_API_TOKEN environment variable missing.'}
JIRA_JQL=${JIRA_JQL:?'JIRA_JQL environment variable missing (ex. filter=15793).'} # 'filter=15793'

# default parameters
ALLOW_ROLLBACK_DEPLOYS=${ALLOW_ROLLBACK_DEPLOYS:=true}
DEBUG=${DEBUG:="false"}

JIRA_CLOUD_ID=${JIRA_CLOUD_ID:=} # 'DUMMY-158c8204-ff3b-47c2-adbb-a0906ccc722b'
JIRA_HOSTNAME=${JIRA_HOSTNAME:=} # 'product-fabric.atlassian.net'

enable_debug
# TODO (tmack) check for newer version via commons.sh method check_for_newer_version
# the above requires the repository to be public and open to the world

# TODO (tmack) can we support bitbucket pipelines rollback, https://confluence.atlassian.com/bitbucket/rollbacks-981147477.html

# Always allow rollback deployments if configured
if [[ "${ALLOW_ROLLBACK_DEPLOYS}" = true && "${bamboo_deploy_rollback}" = true ]]; then
  success "Proceed with the rollback deployment";
fi

# check for Jira Site configuration data
if [[ -z "${JIRA_HOSTNAME}" && -z "${JIRA_CLOUD_ID}" ]]; then
    fail "JIRA_CLOUD_ID or JIRA_HOSTNAME environment variable missing";
fi

API_HOSTNAME="api.atlassian.com"
JIRA_ENDPOINT="/rest/api/2/search?fields=summary&jql=${JIRA_JQL}"

if [[ ! -z "${JIRA_HOSTNAME}" ]]; then
    JIRA_BLOCKERS_URL="https://${JIRA_HOSTNAME}${JIRA_ENDPOINT}"
elif [[ ! -z "${JIRA_CLOUD_ID}" ]]; then
    JIRA_BLOCKERS_URL="https://${API_HOSTNAME}/ex/jira/${JIRA_CLOUD_ID}${JIRA_ENDPOINT}"
fi

# check for Jira Authentication configuration
if [[ -z "${JIRA_USERNAME}" ]]; then
    fail "JIRA_USERNAME environment variable missing";
fi

# current limitation: only supported User API Tokens
if [[ -z "${JIRA_API_TOKEN}" ]]; then
    warning "Create an API Token via instructions provided here: https://confluence.atlassian.com/cloud/api-tokens-938839638.html";
    fail "JIRA_API_TOKEN environment variable missing";
fi

# We fetch all the issues that match the provided JQL search criteria (filter or native JQL supported).
# HTTP_RESPONSE=$(
#   curl -X GET \
#        -w '%{stderr}{"status": %{http_code}, "body":%{stdout}}' -s -o - \
#        --user "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
#        --header 'Accept: application/json' \
#        --url $JIRA_BLOCKERS_URL 2>&1 \
# )

# store the whole response with the status at the and
HTTP_RESPONSE=$(
    curl --silent --write-out "HTTPSTATUS:%{http_code}" \
        --user "${JIRA_USERNAME}:${JIRA_API_TOKEN}" \
        --header 'Accept: application/json' \
        --url $JIRA_BLOCKERS_URL 2>&1 \
)

# extract the body
HTTP_BODY=$(
    echo "$HTTP_RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g'
)

# extract the status
HTTP_STATUS=$(
    echo "$HTTP_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://'
)

debug $HTTP_BODY
debug $HTTP_STATUS

if [ ! $HTTP_STATUS -eq 200 ]; then
  fail "Error: Could not fetch release blockers from Jira [Http Status: $HTTP_STATUS]";
fi

TOTAL=$(echo "$HTTP_BODY" | jq .total);
if [ ! $TOTAL -eq 0 ]; then
  fail "!!!Total of $TOTAL release blocker(s) found in Jira!!!";
else
  success "No release blockers found! Proceed to deployment!";
fi