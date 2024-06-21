#!/usr/bin/env bash
set -eu

source .env

TAG=$(jq -r '.version' CloudronManifest.json)
IMAGE=$(jq -r '.id' CloudronManifest.json)

TAG_EXISTS=$(docker manifest inspect "$REGISTRY"/"$REGISTRY_USER"/"$IMAGE":"$TAG" > /dev/null ; echo $?)

build_image() {
  if [ "$TAG_EXISTS" == "0" ]; then
    echo -e "Tag version \033[1m${TAG}\033[0m already exists at ${REGISTRY}/${REGISTRY_USER}. Update the manifest version value."
    exit 1
  else
    echo "=> Building image..."

    if ! docker build -t "$REGISTRY"/"$REGISTRY_USER"/"$IMAGE":"$TAG" . ; then
      echo "Build failed."
      exit 1
    else
      echo "=> Pushing ${REGISTRY}/${REGISTRY_USER}/${IMAGE}:${TAG} to registry..."
      if ! docker push "$REGISTRY"/"$REGISTRY_USER"/"$IMAGE":"$TAG" ; then
        echo "Pushing image to registry failed."
        exit 1
      fi
    fi
  fi
}

build_image
