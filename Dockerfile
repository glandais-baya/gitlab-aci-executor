FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y openssh-server git curl gpg && rm -rf /var/lib/apt/lists/*

# uploading artifacts/cache needs local gitlab runner executable
RUN curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | os=ubuntu dist=bionic bash

RUN apt-get update && apt-get install gitlab-runner && rm -rf /var/lib/apt/lists/*

RUN mkdir /run/sshd
RUN mkdir ~/.ssh
RUN chmod 700 ~/.ssh

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]