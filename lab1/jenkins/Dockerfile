FROM jenkins/jenkins:lts-jdk11
USER root
RUN apt update && \
    apt install -y --no-install-recommends gnupg curl ca-certificates apt-transport-https
RUN jenkins-plugin-cli --plugins prometheus:2.0.11
USER jenkins