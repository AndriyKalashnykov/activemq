FROM bellsoft/liberica-openjdk-alpine:17.0.9

LABEL maintainer="Andriy Kalashnykov <andriykalashnykov@gmail.com>"

ENV ACTIVEMQ_VERSION 5.18.3
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_HOME /opt/activemq
ENV UID=1000 
ENV GID=1000

RUN apk add --update curl && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /opt && \
    curl -s -S https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz | tar -xvz -C /opt && \
    mv /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    addgroup --gid ${GID} -S activemq && \
    adduser -S -H -u ${UID} -G activemq -h $ACTIVEMQ_HOME activemq

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN chown activemq:activemq /entrypoint.sh

COPY conf/activemq.xml $ACTIVEMQ_HOME/conf/
COPY conf/jetty.xml $ACTIVEMQ_HOME/conf/
COPY conf/jolokia-access.xml $ACTIVEMQ_HOME/conf/
COPY conf/broker.ts $ACTIVEMQ_HOME/conf/
COPY conf/broker.ks $ACTIVEMQ_HOME/conf/
COPY conf/broker.p12 $ACTIVEMQ_HOME/conf/
COPY conf/broker.pem $ACTIVEMQ_HOME/conf/
COPY conf/client.ts $ACTIVEMQ_HOME/conf/
COPY conf/client.p12 $ACTIVEMQ_HOME/conf/
COPY conf/client.pem $ACTIVEMQ_HOME/conf/
COPY conf/client.cert $ACTIVEMQ_HOME/conf/
COPY webapps/api/WEB-INF/web.xml $ACTIVEMQ_HOME/webapps/api/WEB-INF/

RUN chown -R activemq:activemq $ACTIVEMQ_HOME && chown -h activemq:activemq $ACTIVEMQ_HOME

WORKDIR $ACTIVEMQ_HOME
USER activemq
EXPOSE 1099 1883 5672 8161 8162 61613 61614 61616

# VOLUME ["/opt/activemq/data", "/opt/activemq/log"]
ENTRYPOINT ["/entrypoint.sh"]
# CMD ["/opt/activemq/bin/activemq", "console"]