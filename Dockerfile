FROM alpine:3.11

RUN apk add --update --no-cache bash curl jq

COPY src /
COPY LICENSE pipe.yml README.md /
RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.6.0/common.sh

RUN chmod a+x /*.sh

ENTRYPOINT ["/release-blocker.sh"]