#!/bin/bash

fetchArtifactURL() {
    echo https://build.syncthing.net\
$(curl -sS -H Accept:application/json "https://build.syncthing.net\
$(curl -sS -H Accept:application/json "https://build.syncthing.net/guestAuth/app/rest/buildTypes/${1}/builds/${2}" | jq -M -r .artifacts.href)" \
| jq -r '.file[] | select( .name | contains('\"${3}\"')) | .content.href')
}

extractVersionFromURL() {
    echo "${1}" | sed -E "s/^.*-${ARCHITECTURE}-(.*)\.tar\.gz/\\1/"
}

if [ -z "${RELAY_BUILD_ID}" ]; then
    RELAY_ARCHIVE_URL="$(fetchArtifactURL "${RELAY_BUILD_TYPE}" "branch:name:${RELAY_BRANCH}" "${ARCHITECTURE}")"
else
    RELAY_ARCHIVE_URL="$(fetchArtifactURL "${RELAY_BUILD_TYPE}" "id:${RELAY_BUILD_ID}" "${ARCHITECTURE}")"
fi

if [ -z "${DISCOVERY_BUILD_ID}" ]; then
    DISCOVERY_ARCHIVE_URL="$(fetchArtifactURL "${DISCOVERY_BUILD_TYPE}" "branch:name:${DISCOVERY_BRANCH}" "${ARCHITECTURE}")"
else
    DISCOVERY_ARCHIVE_URL="$(fetchArtifactURL "${DISCOVERY_BUILD_TYPE}" "id:$DISCOVERY_BUILD_ID}" "${ARCHITECTURE}")"
fi

if [ "$1" == "--test" ]; then
    echo "relaysrv_$(extractVersionFromURL "$RELAY_ARCHIVE_URL").tar.gz -> ${RELAY_ARCHIVE_URL}"
    echo "discosrv_$(extractVersionFromURL "$DISCOVERY_ARCHIVE_URL").tar.gz -> ${DISCOVERY_ARCHIVE_URL}"
    exit 0
fi


wget -O "relaysrv_$(extractVersionFromURL "$RELAY_ARCHIVE_URL").tar.gz" "${RELAY_ARCHIVE_URL}"
wget -O "discosrv_$(extractVersionFromURL "$DISCOVERY_ARCHIVE_URL").tar.gz" "${DISCOVERY_ARCHIVE_URL}"
ls -la relaysrv* discosrv*
