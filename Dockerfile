FROM openjdk:8

# Database configuration
# Defaults to using H2
ENV SONAR_VERSION=7.0 \
    SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

# Http port
EXPOSE 9000

RUN groupadd -r sonarqube && useradd -r -g sonarqube sonarqube

# grab gosu for easy step-down from root
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && GPG_KEYS=B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --keyserver ct.heise.de --recv-keys "$GPG_KEYS" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEYS" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
RUN set -x \
    && GPG_KEYS=F1182E81C792928921DBCAB4CFCA4A29D26468DE \
    && gpg --keyserver ct.heise.de --recv-keys "$GPG_KEYS" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEYS" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
    && cd /opt \
    && curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && curl -o sonarqube.zip.asc -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:sonarqube sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
ENTRYPOINT ["./bin/run.sh"]
