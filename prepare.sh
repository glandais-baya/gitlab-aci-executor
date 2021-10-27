#!/usr/bin/env bash

# /opt/gitlab-aci-executor/prepare.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -eo pipefail

# trap any error, and mark it as a system failure.
trap "exit $SYSTEM_FAILURE_EXIT_CODE" ERR

# cleanup shm
find /dev/shm -name "gitlab-aci-*" -mtime +1 -print0 | xargs -0 rm -f

if [ -f "/dev/shm/gitlab-ci-${CUSTOM_ENV_CI_PIPELINE_ID}-${CUSTOM_ENV_CI_JOB_NAME}.sh" ]; then
        source /dev/shm/gitlab-ci-${CUSTOM_ENV_CI_PIPELINE_ID}-${CUSTOM_ENV_CI_JOB_NAME}.sh
fi

if [ -n "$CUSTOM_ENV_RUN_ON_HOST" ]; then
        echo "Running on host!"
        exit 0
fi

IMAGE=${CUSTOM_ENV_IMAGE:-m0ppers/gitlab-aci-executor-base}

CPUS="1"
MEM="1.5"
GPUS=0
if [ -n "$CUSTOM_ENV_AZ_CPUS" ]; then
        CPUS="${CUSTOM_ENV_AZ_CPUS}"
fi
if [ -n "$CUSTOM_ENV_AZ_MEM" ]; then
        MEM="${CUSTOM_ENV_AZ_MEM}"
fi
if [ -n "$CUSTOM_ENV_AZ_GPUS" ]; then
        GPUS="${CUSTOM_ENV_AZ_GPUS}"
fi

source ${currentDir}/base.sh # Get variables from base.

start_container () {
    FILE=$(mktemp)
    FILE_FINAL=$(mktemp)
    cat ${currentDir}/template.yml | yq -y --arg image "${IMAGE}" --arg cpu "${CPUS}" --arg mem "${MEM}" --arg gpu "${GPUS}" --arg name "${CONTAINER_ID}" --arg cmd0 "sh" --arg cmd1 "-" --arg cmd1lolyq "c" --arg cmd2 "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys && /usr/sbin/sshd -D" '.properties.containers[0].properties.image = $image | .properties.containers[0].properties.resources.requests.cpu = $cpu | .properties.containers[0].properties.resources.requests.memoryInGB = $mem | .properties.containers[0].name = $name | .properties.containers[0].properties.command = [$cmd0, $cmd1+$cmd1lolyq, $cmd2]' > $FILE
    if [ "$GPUS" -gt "0" ]; then
        cat $FILE | yq -y --arg gpu "${GPUS}" '.properties.containers[0].properties.resources.requests.gpu = {"count": $gpu, "sku": "K80"}' > $FILE_FINAL
    else
        cp $FILE $FILE_FINAL
    fi
    echo "Creating container ${CONTAINER_ID}"
    az container create --resource-group "$RESOURCE_GROUP" --name ${CONTAINER_ID} --file ${FILE_FINAL} > $FILE
    echo "Container created"
    # debug
    # cat $FILE
    IP=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_ID" | jq -r .ipAddress.ip)
    rm $FILE
    rm $FILE_FINAL
    echo "Waiting for $IP:22"
    while ! nc -z $IP 22; do   
        sleep 1
        echo "Still not accessible"
    done
#     timeout 60 sh -c 'until nc -G 1 -z $0 $1; do sleep 1; done' $IP 22
    echo "Getting ssh keys for $IP"
    ssh -o StrictHostKeyChecking=no root@"$IP" "echo ping"
    echo "Got ssh keys for $IP"
    echo "Container ready"
}

echo "Running in $CONTAINER_ID"

start_container
