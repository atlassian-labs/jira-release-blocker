FROM alpine:3.9

RUN apk add --update --no-cache bash

COPY src /
COPY LICENSE.txt pipe.yml README.md /
RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.6.0/common.sh

RUN chmod a+x /*.sh

ENTRYPOINT ["/release-blocker.sh"]