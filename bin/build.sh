#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash
#
# Build the .deb package using gbp (git-buildpackage).
# Automatically runs inside Docker when executed on the host.
#
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
DOCKER_IMAGE="offline-lab-metapackage-builder"

#
# Check if running inside a container
#
function build::is_container() {
    [[ -f /.dockerenv ]] || grep -qsw docker /proc/1/cgroup 2>/dev/null
}

#
# Build the docker image and re-execute this script inside it
#
function build::run_in_docker() {
    local git_user git_email
    git_user="$(git config user.name)"
    git_email="$(git config user.email)"

    echo "==> Building Docker image..."
    docker build -t "${DOCKER_IMAGE}" "${REPO_ROOT}"

    echo "==> Starting build in Docker..."
    docker run --rm \
        -v "${REPO_ROOT}:/build" \
        -w /build \
        -e "GIT_USER=Offline Lab" \
        -e "GIT_EMAIL=info@offline-lab.com" \
        -e "EMAIL=info@offline-lab.com" \
        "${DOCKER_IMAGE}" \
        ./bin/build.sh "$@"
}

#
# Run the actual build inside the container
#
function build::run() {
    local git_user="${GIT_USER:?GIT_USER not set}"
    local git_email="${GIT_EMAIL:?GIT_EMAIL not set}"

    git config user.name "${git_user}"
    git config user.email "${git_email}"
    git config --global --add safe.directory /build

    current="$(git branch --show-current)"

    echo "==> Updating changelog..."
    gbp dch --auto --distribution=stable --debian-branch="${current}" --commit

    echo "==> Building package..."
    dpkg-buildpackage -us -uc -b

    mkdir -p dist
    mv ../*.deb dist/

    dh clean

    ls dist/*.deb
    echo "==> Build complete."
    echo "==> Don't forget to git push (changelog was committed inside Docker)."
}

#
# Main
#
function build::main() {
    if build::is_container; then
        build::run
    else
        build::run_in_docker "$@"
    fi
}

build::main "$@"
