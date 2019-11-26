#!/bin/bash

if [ -z "$LFS_URL" ]; then
    exit 0
fi

if [ -n "$LFS_DISABLE_CERT_CHECK" ]; then
    git config --global http.sslVerify false
fi
git config --global credential.helper store
git config --global credential.https://${LFS_URL}.username ${LFS_USERNAME}
echo "https://${LFS_USERNAME}:${LFS_PASSWORD}@${LFS_URL_ENCODED}" > ~/.git-credentials