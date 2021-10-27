# Gitlab Azure Container Instance Executor

## Installation

This is assuming a debian buster installation. Might vary!

```
apt-get update
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
apt-get install -y python3-pip jq git-lfs docker.io gitlab-runner
pip3 install yq
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
ssh-keygen
```

Connect to Azure :

```
az login --allow-no-subscriptions
```

Clone this repo to /opt/gitlab-aci-executor

```
cd /opt/
git clone https://gitlab.com/m0ppers/gitlab-aci-executor.git
cd /opt/gitlab-aci-executor
ssh-keygen
```

Register runner

```
gitlab-runner register --url https://gitlab.com/ --registration-token XXXXXXXXX
```

Choose `custom` when it asks for executor type.

Your full config might now look like this:

```
concurrent = 8
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "gitlab-aci-executor"
  url = "https://gitlab.com/"
  token = "XXXXXXXXX"
  executor = "custom"
  builds_dir = "/builds"
  cache_dir = "/cache"
  [runners.custom_build_dir]
    enabled = true
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.custom]
    prepare_exec = "/opt/gitlab-aci-executor/prepare.sh"
    run_exec = "/opt/gitlab-aci-executor/run.sh"
    cleanup_exec = "/opt/gitlab-aci-executor/cleanup.sh"
```

Restart the runner:

```
systemctl restart gitlab-runner
```
