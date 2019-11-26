#!/usr/bin/env bash

# /opt/lxd-executor/cleanup.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

echo "Deleting container $CONTAINER_ID"

az container delete --resource-group kotzilla --name "$CONTAINER_ID" -y
