#!/usr/bin/env bash

# /opt/gitlab-aci-executor/run.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

if [ -f "/dev/shm/gitlab-ci-${CUSTOM_ENV_CI_PIPELINE_ID}-${CUSTOM_ENV_CI_JOB_NAME}.sh" ]; then
        source /dev/shm/gitlab-ci-${CUSTOM_ENV_CI_PIPELINE_ID}-${CUSTOM_ENV_CI_JOB_NAME}.sh
        echo -e "$(cat /dev/shm/gitlab-ci-${CUSTOM_ENV_CI_PIPELINE_ID}-${CUSTOM_ENV_CI_JOB_NAME}.sh)\n$(cat ${1})" > ${1}
fi

if [ -n "$CUSTOM_ENV_RUN_ON_HOST" ]; then
        echo "Running on host!"
        /bin/bash < "${1}"
        if [ $? -ne 0 ]; then
            # Exit using the variable, to make the build as failure in GitLab
            # CI.
            exit $BUILD_FAILURE_EXIT_CODE
        fi
        exit 0
fi

echo "Building in $CONTAINER_ID ${*}"


IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_ID" | jq -r .ipAddress.ip)

ssh -o "ServerAliveInterval=30" -t "$IP" /bin/bash < "${1}"
RESULT="$?"
if [ $RESULT -ne 0 ]; then
    # Exit using the variable, to make the build as failure in GitLab
    # CI.
    exit $BUILD_FAILURE_EXIT_CODE
fi
