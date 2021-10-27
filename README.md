# Gitlab Azure Container Instance Executor

## Installation

This is assuming a debian buster installation. Might vary!

```
apt-get install -y python3-pip jq docker.io
pip3 install yq
```

Install azure client and login:

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest

Install and configure gitlab runner as specified in the gitlab docs:

https://docs.gitlab.com/runner/install/linux-repository.html

Choose `custom` when it asks for executor type.

Clone this repo to /opt/gitlab-aci-executor

Setup a ssh key:

```
ssh-keygen
```

Setup gitlab runner cache. If you want to use local storage check out this minio guide:

https://docs.gitlab.com/runner/install/registry_and_cache_servers.html#install-your-own-cache-server

Finally activate the executor in /etc/gitlab-runner/config.toml:

```
  [runners.custom]
    prepare_exec = "/opt/gitlab-aci-executor/prepare.sh"
    run_exec = "/opt/gitlab-aci-executor/run.sh"
    cleanup_exec = "/opt/gitlab-aci-executor/cleanup.sh"
```

Your full config might now look like this:

```
concurrent = 8
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "debian-gitlab-runner"
  url = "https://gitlab.com/"
  token = "GITLAB_TOKEN"
  executor = "custom"
  builds_dir = "/builds"
  cache_dir = "/cache"
  [runners.custom_build_dir]
    enabled = true
  [runners.cache]
    Type = "s3"
    Path = ""
    Shared = false
    [runners.cache.s3]
      ServerAddress = "MYIP:9005"
      AccessKey = "MinioAccessKey"
      SecretKey = "MinioSecreyKey"
      BucketName = "runner"
      Insecure = true
    [runners.cache.gcs]
  [runners.custom]
    prepare_exec = "/opt/gitlab-aci-executor/prepare.sh"
    run_exec = "/opt/gitlab-aci-executor/run.sh"
    cleanup_exec = "/opt/gitlab-aci-executor/cleanup.sh"
```

Restart the runner:

```
systemctl restart gitlab-runner
```
