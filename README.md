[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FAndriyKalashnykov%2Factivemq&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
## Dockerized ActiveMQ with HTTPS endpoinds.

Based on [bellsoft/liberica-openjdk-alpine:17](https://hub.docker.com/r/bellsoft/liberica-openjdk-alpine), lightweight and multi-arch (Apple M1/M2/aarch64/arm64)

## Usage

```bash
docker run -it -p 1099:1099 -p 8161:8161 -p 61616:61616 andriykalashnykov/activemq:latest
```

Bind more ports and environment variables:

```bash
docker run -it \
-p 1099:1099 \
-p 1833:1833 \
-p 5672:5672 \
-p 8161:8161 \
-p 8162:8162 \
-p 61613:61613 \
-p 61614:61614 \
-p 61616:61616 \
-p 25672:25672 \
-p 26613:26613 \
-p 26614:26614 \
-p 26616:26616 \
-p 28883:28883 \
-e ACTIVEMQ_USERNAME=admin \
-e ACTIVEMQ_PASSWORD=admin \
-e ACTIVEMQ_WEBADMIN_USERNAME=admin \
-e ACTIVEMQ_WEBADMIN_PASSWORD=admin \
andriykalashnykov/activemq:latest

openssl s_client -connect localhost:26616 -debug
```

## ActiveMQ version

Current version of ActiveMQ is **5.18.3**: https://archive.apache.org/dist/activemq/5.18.3/

Note: Since ActiveMQ 5.16.0 the Web Console is not reachable by default, as it only listens to 127.0.0.1 inside the container. See [AMQ-8018](https://issues.apache.org/jira/browse/AMQ-8018) for more details.

## Settings

You can define the following environment variables to control the behavior. 

| Environment Variable                    | Default | Description                                                                                                                                                                   |
|:----------------------------------------|:--------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ACTIVEMQ_USERNAME                       | system  | [Security](https://activemq.apache.org/security) (credentials.properties)                                                                                                     |
| ACTIVEMQ_PASSWORD                       | manager | [Security](https://activemq.apache.org/security) (credentials.properties)                                                                                                     |
| ACTIVEMQ_WEBADMIN_USERNAME              | admin   | [WebConsole](https://activemq.apache.org/security) (jetty-realm.properties)                                                                                                   |
| ACTIVEMQ_WEBADMIN_PASSWORD              | admin   | [WebConsole](https://activemq.apache.org/security) (jetty-realm.properties)                                                                                                   |
| ACTIVEMQ_WEBCONSOLE_USE_DEFAULT_ADDRESS | false   | Set default behavior of ActiveMQ Jetty listen address (127.0.0.1). By default, WebConsole listens on all addresses (0.0.0.0), so you can reach/map the WebConsole port (8161) |
| ACTIVEMQ_ADMIN_CONTEXTPATH              | /admin  | [WebConsole](https://github.com/apache/activemq/blob/main/assembly/src/release/conf/jetty.xml) Set contextPath of WebConsole (jetty.xml)                                      |
| ACTIVEMQ_API_CONTEXTPATH                | /api    | [API](https://github.com/apache/activemq/blob/main/assembly/src/release/conf/jetty.xml) Set contextPath of API (jetty.xml)                                                    |
| ACTIVEMQ_ENABLE_SCHEDULER               | false   | Enable the scheduler by setting `schedulerSupport` to `true` in `activemq.xml`|


## Exposed Ports

The following ports are exposed and can be bound:

| Port  | Description |
|:------|:------------|
| 1099  | JMX         |
| 1883  | MQTT        |
| 5672  | AMPQ        |
| 8161  | WebConsole  |
| 61613 | STOMP       |
| 61614 | WS          |
| 61616 | OpenWire    |

## Build

```bash
./build.sh
```

## Publish

First, commit your change to Git. 

```bash
git commit -m "Update ActiveMQ to 5.18.3"
```

Then tag it. 

```bash
git tag -a v5.18.3 -m "Release 5.18.3"
```

Then push it to Github.

```bash
git push && git push origin --tags
```

Publishing manually:

```bash
docker login
docker tag andriykalashnykov/activemq:5.18.3 andriykalashnykov/activemq:latest
docker push andriykalashnykov/activemq:5.18.3
docker push andriykalashnykov/activemq:latest
```

## Multi Architecture Docker Build

Then build for multiple platforms:

```bash
# Prepare the buildx context and use it
BUILDER_NAME=$(docker buildx create) && docker buildx use $BUILDER_NAME
docker buildx build --push --platform linux/arm64,linux/amd64 --tag andriykalashnykov/activemq:5.18.3 .
docker buildx build --push --platform linux/arm64,linux/amd64 --tag andriykalashnykov/activemq:latest .
```

## Send a message via ActiveMQ REST API

```bash
curl -u admin:admin -d "body=message" http://localhost:8161/api/message/TEST?type=queue -H 'Origin: http://http://localhost/'
curl -u admin:admin -d 'hello world 1' -H 'Origin: http://localhost' -H 'Content-Type: text/plain' -XPOST 'http://localhost:8161/api/message?destination=queue://empi-Master-persistence'
curl -u admin:admin -d "body=message" http://localhost:8161/api/message/empi-Master-persistence?type=queue -H 'Origin: http://localhost'
( echo -n "body="  ;  cat /home/andriy/projects/minikube-cluster/k8s/cdr/assets/rec.json ) | curl -H 'Origin: http://localhost' --data-binary '@-' -d 'customProperty=value' 'http://admin:admin@192.168.200.2:8161/api/message/q1?type=queue'
curl -XGET -u admin:admin -H 'Origin: http://localhost/' http://localhost:8161/api/jolokia/list
```

## SSL

```bash
openssl s_client -connect 192.168.200.2:8162 -CAfile conf/broker.pem
curl -k -u admin:admin -d "body=message" https://192.168.200.2:8162/api/message/TEST?type=queue --pass '' --cert conf/broker.pem
curl -k -u admin:admin -GET https://192.168.200.2:8162/api/jolokia/list --pass '' --cert conf/broker.pem
wget --no-check-certificate --http-user=admin --http-password=admin --post-data="body=test" https://192.168.200.2:8162/api/message/TEST?type=queue --ca-certificate=conf/broker.pem -O /dev/null -o /dev/null
wget --no-check-certificate --http-user=admin --http-password=admin --post-data="body=test" https://192.168.200.2:8162/api/jolokia/list --ca-certificate=conf/broker.pem -O /dev/null -o /dev/null
```

## References

* [Helm chart for ActiveMQ](https://github.com/disaster37/activemq-kube/blob/master/deploy/helm/activemq/templates/statefullset.yaml)
* [Docker image for ActiveMQ](https://github.com/disaster37/activemq/blob/master/assets/entrypoint/entrypoint/Init.py)
