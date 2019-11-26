#!/usr/bin/env bash

LFS_URL="$1"
LFS_URL_ENCODED="$2"
LFS_DISABLE_CERT_CHECK="$3"
LFS_USERNAME="$4"
LFS_PASSWORD="$5"

if [ -z "$LFS_URL" ]; then
    echo "Skipping LFS setup"
    exit 0
fi

if [ -n "$LFS_DISABLE_CERT_CHECK" ]; then
    ssh "$IP" git config --global http.sslVerify false
fi
ssh "$IP" git config --global credential.helper store
ssh "$IP" git config --global credential.https://kotzilla-lfs.akronyme-analogiker.jetzt:8080.username gitlab
ssh "$IP" 'echo "https://gitlab:ballerngeil@kotzilla-lfs.akronyme-analogiker.jetzt%3a8080" > ~/.git-credentials'