#!/bin/bash
set -e

here=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
set -a  # enable allexport
. "$here/.env"
set +a  # disable allexport


DOCKER_IMAGE="python"
DOCKER_TAG="3.7"

# shellcheck disable=2207
IFS=$'\n' VSINFO=( $(code --version) )
COMMIT="${VSINFO[1]}"

if compgen -G "vscode-server-linux*${COMMIT}*.tar.gz" >/dev/null; then
  echo "No matching vscode server binary found: ${COMMIT}"
  exit 1
fi

DUID=$(id -u)
DGID=$(id -g)
DPW=${DOCKERPASSWD:=docker}
DUSER='vscode'
DGROUP='build'

if [[ -f "$here/.env" ]];then
    sed -i '/^VSCODE_COMMIT=.*/d' "$here/.env"
fi
echo "VSCODE_COMMIT=${COMMIT}" >> "$here/.env"


# NOTE: Avoid UID as it's normally read-only yet not passed to compose
if [[ -f "$here/.env" ]];then
    sed -i '/^USER_ID=.*/d' "$here/.env"
fi
echo "USER_ID=${DUID}" >> "$here/.env"

echo "uid=${DUID},commit=${COMMIT}"

BUILD_TAG="$DOCKER_IMAGE-vscode:$DOCKER_TAG-$COMMIT-$DUID"
echo "$BUILD_TAG"

docker build -t "$BUILD_TAG" \
  --build-arg "COMMIT=$COMMIT" \
  --build-arg "USER=$DUSER" \
  --build-arg "GROUP=$DGROUP" \
  --build-arg "UID=$DUID" \
  --build-arg "GUID=$DGID" \
  --build-arg "PW=$DPW" \
  -f "$here/.devcontainer/devcontainer.dockerfile" \
  "$here/.devcontainer"
