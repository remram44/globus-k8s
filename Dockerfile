FROM ubuntu:22.04

ARG GLOBUS_CONNECT_PERSONAL_VERSION=3.2.2
ARG GLOBUS_CONNECT_PERSONAL_TAR_HASH=178b2110dcab41f3b58da675fa989afc3ad3b625b8d95ef0fc9523a13295fdc2

RUN apt-get update && \
    apt-get install -yy curl python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -Lo /tmp/globusconnectpersonal-${GLOBUS_CONNECT_PERSONAL_VERSION}.tar.gz https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz &&\
    printf "${GLOBUS_CONNECT_PERSONAL_TAR_HASH}  /tmp/globusconnectpersonal-${GLOBUS_CONNECT_PERSONAL_VERSION}.tar.gz\\n" | sha256sum -c && \
    mkdir -p /opt/globusconnectpersonal && \
    tar -xf /tmp/globusconnectpersonal-${GLOBUS_CONNECT_PERSONAL_VERSION}.tar.gz --strip-components=1 -C /opt/globusconnectpersonal && \
    rm /tmp/globusconnectpersonal-${GLOBUS_CONNECT_PERSONAL_VERSION}.tar.gz

RUN mkdir /var/lib/globus && chmod 1777 /var/lib/globus

RUN adduser --uid 1000 globus
USER 1000

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 setup /usr/local/bin/setup
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
