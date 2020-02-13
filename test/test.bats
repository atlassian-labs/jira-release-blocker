setup() {
  DOCKER_IMAGE=${DOCKER_IMAGE:="test/release-blocker-pipe"}

  echo "Building image..."
  docker build -t ${DOCKER_IMAGE}:test .
}

@test "Requires JIRA_USERNAME Argument" {
    run docker run \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"JIRA_USERNAME environment variable missing"* ]]
}

@test "Requires JIRA_API_TOKEN Argument" {
    run docker run \
        -e JIRA_USERNAME="username@atlassian.com" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"JIRA_API_TOKEN environment variable missing"* ]]
}

@test "Requires JIRA_JQL Argument" {
    run docker run \
        -e JIRA_USERNAME="username@atlassian.com" \
        -e JIRA_API_TOKEN="my-api-token" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"JIRA_JQL environment variable missing"* ]]
}

@test "Requires JIRA_CLOUD_ID or JIRA_HOSTNAME Argument" {
    run docker run \
        -e JIRA_USERNAME="username@atlassian.com" \
        -e JIRA_API_TOKEN="my-api-token" \
        -e JIRA_JQL="filter=1234" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"JIRA_CLOUD_ID or JIRA_HOSTNAME environment variable missing"* ]]
}
