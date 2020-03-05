# release-blockers-pipe
When building web applications industry best practicies are to have a CI/CD (continuous integration and continuous delivery) pipeline put in place. With Bitbucket Pipelines this is as easy as providing a bitbucket-pipelines.yml file that contains the logic and code to do just that. However, infrequently the development team might want to block releases to their production environment due to various reasons (earnings calls, major traffic days, release windows, significant new feature, change review, and several more). 

A great way to implement this type of release block is to configure a Jira Issue as a "release blocker" (typically using labels). Whenever this release blocker is found the release to your production environment the release pipeline would bail over before continuing waiting for a human to resolve the release blocker ticket.

This [Bitbucket Pipelines Pipe](https://bitbucket.org/product/features/pipelines/integrations) will query the provided JQL and/or Jira Filter (cloud only) and will block any and all deployments to the configured environments if Jira Issues are found as a result of the provided search.

## YAML Definition
Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

### (preferred) Bitbucket Repository Reference

When referencing a Bitbucket Pipe via a repository reference `<owner>/<repo>:<tag>` this tells Bitbucket Pipelines to look at the relative `pipes.yml` within that repository for where to find the Pipe Docker image. This is best as this allows the DockerHub namespace to change over time if needed.

```yaml
script:
  - pipe: atlassian/release-blockers-pipe:0.0.3
    variables:
      JIRA_JQL: "<string>"
      JIRA_CLOUD_ID: "<string>"
      JIRA_USERNAME: "<string>"
      JIRA_API_TOKEN: $JIRA_API_TOKEN # DO NOT type value of api_token here, instead store as "secure" environment variable in pipelines settings
      # JIRA_HOSTNAME: "<string>" # Optional, required if JIRA_CLOUD_ID not specified
```

### Docker Image Reference

```yaml
script:
  - pipe: docker://tmack8001/release-blockers-pipe:0.0.3
    variables:
      JIRA_JQL: "<string>"
      JIRA_CLOUD_ID: "<string>"
      JIRA_USERNAME: "<string>"
      JIRA_API_TOKEN: $JIRA_API_TOKEN # DO NOT type value of api_token here, instead store as "secure" environment variable in pipelines settings
      # JIRA_HOSTNAME: "<string>" # Optional, required if JIRA_CLOUD_ID not specified
```

## Variables

| Variable               | Usage                                                                        |
| ---------------------- | ---------------------------------------------------------------------------- |
| JIRA_JQL (*)           | Jira Query Language (JQL) for executing a search against a Jira Instance.    |
| JIRA_CLOUD_ID (1*)     | Cloud ID of the Jira Site to execute a search against.                       |
| JIRA_HOSTNAME (1*)     | Jira Hostname to use if Jira Cloud ID isn't specified.                       |
| JIRA_USERNAME (*)      | Username of the user you want this pipe to query Jira with (remember project permissions). Typically the username/email used to log into the Atlassian Account (via id.atlassian.net) which has access to the Jira you want to query.                        |
| JIRA_API_TOKEN (***)   | API Token associated with JIRA_USERNAME stored as a secure environment variable. |
| ALLOW_ROLLBACK_DEPLOYS | Boolean to opt rollback deploys into release blockers. Default: `true`           |
| DEBUG                  | Turn on extra debug information. Default: `false`.                               |

_(*) = required variable._

_(***) = required secure environment variable._

_(1*) = at least one of these variables is required._

## Support
If you’d like help with this pipe, or you have an issue or feature request, let us know.
The pipe is maintained by tmack@atlassian.com.

If you’re reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce