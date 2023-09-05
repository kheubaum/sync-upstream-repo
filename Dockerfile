FROM oraclelinux:9-slim

RUN microdnf install git

RUN adduser -m ci

ADD *.sh /home/ci/

RUN chmod 555 /home/ci/*.sh

ENTRYPOINT ["/home/ci/entrypoint.sh"]
