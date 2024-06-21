#!/usr/bin/env bash
set -e

source .env

usage() {
  echo "Syntax: update.sh [-l]"
  echo "Options:"
  echo "l   Set the environment to operate onto."
  echo 1>&2; exit 1; 
}

while getopts ":l:" o; do
  case $o in
    l)
      l=$OPTARG
      ((l == "prod" || l == "test")) || usage
      ;;
    *)
      echo "Invalid option"
      usage
      ;;
  esac
done

update() {
  TAG=$(jq -r '.version' CloudronManifest.json)
  IMAGE=$(jq -r '.id' CloudronManifest.json)

  TAG_EXISTS=$(docker manifest inspect "$REGISTRY"/"$REGISTRY_USER"/"$IMAGE":"$TAG" > /dev/null ; echo $?)

  if [ ! "$TAG_EXISTS" == "0" ]; then
    echo -e "Tag version \033[1m${TAG}\033[0m does not exists."
    exit 1
  else
    if [ "$l" == "prod" ]; then
      APP_EXISTS=$(cloudron --server "$CLOUDRON_SERVER" --token "$CLOUDRON_TOKEN" status --app "$PROD_APP_ENDPOINT" > /dev/null ; echo $?)

      if [ ! "$APP_EXISTS" == "0" ]; then
        echo -e "Application \033[1m${PROD_APP_ENDPOINT}\033[0m not found on ${CLOUDRON_SERVER}" 
        exit 1
      else
        echo "=> Updating application..."

        if ! cloudron update --image "$REGISTRY"/"$REGISTRY_USER"/"$IMAGE":"$TAG" --app "$PROD_APP_ENDPOINT" ; then
          echo "Application update failed."
          exit 1
        else
          exit 0
        fi
      fi
    elif [ "$l" == "test" ]; then
      APP_EXISTS=$(cloudron --server "$CLOUDRON_SERVER" --token "$CLOUDRON_TOKEN" status --app "$TEST_APP_ENDPOINT" > /dev/null ; echo $?)

      if [ ! "$APP_EXISTS" == "0" ]; then
        echo -e "Application \033[1m${TEST_APP_ENDPOINT}\033[0m not found on ${CLOUDRON_SERVER}" 
        exit 1
      else
        echo "=> Updating application..."

        if ! cloudron update --image "$REGISTRY"/"$REGISTRY_USER"/"$IMAGE":"$TAG" --app "$TEST_APP_ENDPOINT" --no-backup ; then
          echo "Application update failed."
          exit 1
        else
          exit 0
        fi
      fi
    fi
  fi 
}

update
