#!/usr/bin/env bash

# /opt/gitlab-aci-executor/cleanup.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

echo "Deleting container $CONTAINER_ID"

az container delete --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_ID" -y
