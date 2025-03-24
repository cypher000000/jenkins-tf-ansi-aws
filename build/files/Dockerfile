# syntax=docker/dockerfile:1
#--------------------------------------------------------------
# Dockefile to build Docker Image of demo-java-app by tongueroo
#
# Made by cypher000000. 10-03-2025
#
# Original by tongueroo https://github.com/tongueroo/demo-java
#--------------------------------------------------------------
FROM maven:3.6.3-jdk-8-slim AS maven
WORKDIR /tmp/maven/
RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/* 
RUN git clone https://github.com/tongueroo/demo-java/ /tmp/maven/
RUN mvn package

FROM tomcat:8.5
COPY --from=maven /tmp/maven/target/demo.war /usr/local/tomcat/webapps/demo.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
