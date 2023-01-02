#!/bin/bash

fetchBuildDetails() {
    curl -sS -H Accept:application/json "https://build.syncthing.net/guestAuth/app/rest/buildTypes/${1}/builds/${2}"
}

fetchArtifactURL() {
    echo "https://build.syncthing.net$(curl -sS -H Accept:application/json "https://build.syncthing.net$(fetchBuildDetails "$1" "$2" | jq -M -r .artifacts.href)" \
    | jq -r '.file[] | select( .name | contains('\"${3}\"')) | .content.href')"
}

fetchReleaseTagCommit() {
    REPO="syncthing/syncthing"
    if [ -z "$1" ]; then
        RELEASE="latest"
    else
        RELEASE="tags/$1"
    fi
    TAG="$(curl -sS "https://api.github.com/repos/$REPO/releases/$RELEASE" | jq -r '.tag_name')"
    read TYPE TAG_SHA < <(echo $(curl -sS "https://api.github.com/repos/$REPO/git/ref/tags/$TAG" | jq -r '.object.type,.object.sha'))
    if [[ "$TYPE" == "commit" ]]; then
        echo "$TAG_SHA"
    else
        echo "$(curl -sS "https://api.github.com/repos/$REPO/git/tags/$TAG_SHA" | jq -r '.object.sha')"
    fi
}

extractVersionFromURL() {
    echo "${1}" | sed -E "s/^.*-${ARCHITECTURE}-(.*)\.tar\.gz/\\1/"
}

if [ -z "${RELEASE_TAG}" ]; then
    LATEST_RELEASE_TAG_NAME="$(curl -sS https://api.github.com/repos/syncthing/syncthing/releases/latest | jq .tag_name)"
    LATEST_RELEASE_COMMIT="$(fetchReleaseTagCommit)"
    RELAY_ARCHIVE_URL="$(fetchArtifactURL "${RELAY_BUILD_TYPE}" "branch:name:${RELAY_BRANCH}" "${ARCHITECTURE}")"
    DISCOVERY_ARCHIVE_URL="$(fetchArtifactURL "${DISCOVERY_BUILD_TYPE}" "branch:name:${DISCOVERY_BRANCH}" "${ARCHITECTURE}")"
else
    LATEST_RELEASE_COMMIT="$(fetchReleaseTagCommit $RELEASE_TAG)"
    RELAY_ARCHIVE_URL="$(fetchArtifactURL "${RELAY_BUILD_TYPE}" "revision:${LATEST_RELEASE_COMMIT}" "${ARCHITECTURE}")"
    DISCOVERY_ARCHIVE_URL="$(fetchArtifactURL "${DISCOVERY_BUILD_TYPE}" "revision:${LATEST_RELEASE_COMMIT}" "${ARCHITECTURE}")"
fi

if [[ "$1" == "--test" ]]; then
    echo "relaysrv_$(extractVersionFromURL "$RELAY_ARCHIVE_URL").tar.gz -> ($(fetchBuildDetails "${RELAY_BUILD_TYPE}" "branch:name:${RELAY_BRANCH}" | jq .number)) ${RELAY_ARCHIVE_URL}"
    echo "discosrv_$(extractVersionFromURL "$DISCOVERY_ARCHIVE_URL").tar.gz -> ($(fetchBuildDetails "${DISCOVERY_BUILD_TYPE}" "branch:name:${DISCOVERY_BRANCH}" | jq .number)) ${DISCOVERY_ARCHIVE_URL}"
    exit 0
fi


wget -O "relaysrv_$(extractVersionFromURL "$RELAY_ARCHIVE_URL").tar.gz" "${RELAY_ARCHIVE_URL}"
wget -O "discosrv_$(extractVersionFromURL "$DISCOVERY_ARCHIVE_URL").tar.gz" "${DISCOVERY_ARCHIVE_URL}"
ls -la relaysrv* discosrv*
