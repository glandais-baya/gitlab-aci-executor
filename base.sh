#!/usr/bin/env bash

# /opt/gitlab-aci-executor/base.sh

# no idea why they were not using dirname directly?
currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CONTAINER_ID="runner-$CUSTOM_ENV_CI_RUNNER_ID-project-$CUSTOM_ENV_CI_PROJECT_ID-concurrent-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID-$CUSTOM_ENV_CI_JOB_ID"

RESOURCE_GROUP="$CUSTOM_ENV_AZ_RESOURCE_GROUP"
