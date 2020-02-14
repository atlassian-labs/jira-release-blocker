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

@test "JIRA_CLOUD_ID provided fails 404" {
    run docker run \
        -e JIRA_USERNAME="${JIRA_USERNAME}" \
        -e JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
        -e JIRA_JQL="filter=1234" \
        -e JIRA_CLOUD_ID="1234" \
        -e DEBUG="true" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Could not fetch release blockers from Jira [Http Status: 404]"* ]]
}

@test "JIRA_HOSTNAME provided fails 404" {
    run docker run \
        -e JIRA_USERNAME="${JIRA_USERNAME}" \
        -e JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
        -e JIRA_JQL="filter=1234" \
        -e JIRA_HOSTNAME="ignored-non-existent.atlassian.net" \
        -e DEBUG="true" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Could not fetch release blockers from Jira [Http Status: 404]"* ]]
}

@test "JIRA_HOSTNAME provided no release blockers found" {
    run docker run \
        -e JIRA_USERNAME="${JIRA_USERNAME}" \
        -e JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
        -e JIRA_JQL="labels=%22release-blocker-not-found%22" \
        -e JIRA_HOSTNAME="hello.atlassian.net" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 0 ]
    [[ "$output" == *"No release blockers found! Proceed to deployment!"* ]]
}

@test "JIRA_CLOUD_ID provided no release blockers found" {
  skip "Stargate currently doesn't allow API_TOKEN as authentication to Jira APIs, but will soon"

    run docker run \
        -e JIRA_USERNAME="${JIRA_USERNAME}" \
        -e JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
        -e JIRA_JQL="labels=%22release-blocker-not-found%22" \
        -e JIRA_CLOUD_ID="a436116f-02ce-4520-8fbb-7301462a1674" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 0 ]
    [[ "$output" == *"No release blockers found! Proceed to deployment!"* ]]
}

@test "JIRA_CLOUD_ID provided finds release blocker" {
    skip "Stargate currently doesn't allow API_TOKEN as authentication to Jira APIs, but will soon"

    run docker run \
        -e JIRA_USERNAME="${JIRA_USERNAME}" \
        -e JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
        -e JIRA_JQL="labels=%22release-blocker%22" \
        -e JIRA_CLOUD_ID="a436116f-02ce-4520-8fbb-7301462a1674" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"release blocker(s) found in Jira!!!"* ]]
}

@test "JIRA_HOSTNAME provided finds release blocker" {
    run docker run \
        -e JIRA_USERNAME="${JIRA_USERNAME}" \
        -e JIRA_API_TOKEN="${JIRA_API_TOKEN}" \
        -e JIRA_JQL="labels=%22release-blocker%22" \
        -e JIRA_HOSTNAME="hello.atlassian.net" \
        -v $(pwd):$(pwd) \
        -w $(pwd) \
        ${DOCKER_IMAGE}:test

    echo "Status: $status"
    echo "Output: $output"

    [ "$status" -eq 1 ]
    [[ "$output" == *"release blocker(s) found in Jira!!!"* ]]
}
