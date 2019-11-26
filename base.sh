#!/usr/bin/env bash

# /opt/gitlab-aci-executor/base.sh

# no idea why they were not using dirname directly?
currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CONTAINER_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID-$CUSTOM_ENV_CI_JOB_ID"

if [ ! -f "${currentDir}/config.sh" ]; then
    echo "Please create a config.sh"
    exit 1
fi

source ${currentDir}/config.sh
