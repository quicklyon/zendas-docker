#!/bin/bash
#
# Library for managing Easysoft components

[ -n "${DEBUG:+1}" ] && set -x

# Constants
CACHE_ROOT="/tmp/easysoft/pkg/cache"
DOWNLOAD_URL="https://pkg-hk.qucheng.com/files/stacksmith"
ZENDAS_URL="https://dl.cnezsoft.com/zendas"

# Functions

########################
# Download and unpack a Easysoft software
# Globals:
#   OS_NAME
#   OS_ARCH
# Arguments:
#   $1 - software's name
#   $2 - software's version
# Returns:
#   None
#########################
z_download() {
    local name="${1:?software name is required}"
    local version="${2:?version is required}"
    local zdas_base_name="ZenDAS.${version}.stable.linux64.zip"
    local directory="/apps/"
    echo "Downloading $name:$version package"
    case $name in
    "zendas")
        wget --no-check-certificate --quiet --output-document=/tmp/"${1}" "${ZENDAS_URL}/${version}.stable/${zdas_base_name}"
        unzip -qq -d ${directory} /tmp/"${1}" && rm -rf /apps/zdoo/www/data
        rm /tmp/"${1}"
        ;;
    *)
        echo "$1 does not support download yet."
        exit 1
        ;;
    esac
}

########################
# Download and unpack a Easysoft package
# Globals:
#   OS_NAME
#   OS_ARCH
# Arguments:
#   $1 - component's name
#   $2 - component's version
# Returns:
#   None
#########################
component_unpack() {
    local name="${1:?name is required}"
    local version="${2:?version is required}"
    local base_name="${name}-${version}-${OS_NAME}-${OS_ARCH}"
    local package_sha256=""
    local directory="/"

    # Validate arguments
    shift 2
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -c|--checksum)
                shift
                package_sha256="${1:?missing package checksum}"
                ;;
            *)
                echo "Invalid command line flag $1" >&2
                return 1
                ;;
        esac
        shift
    done

    echo "Downloading $base_name package"
    if [ -f "${CACHE_ROOT}/${base_name}.tar.gz" ]; then
        echo "${CACHE_ROOT}/${base_name}.tar.gz already exists, skipping download."
        cp "${CACHE_ROOT}/${base_name}.tar.gz" .
        rm "${CACHE_ROOT}/${base_name}.tar.gz"
        if [ -f "${CACHE_ROOT}/${base_name}.tar.gz.sha256" ]; then
            echo "Using the local sha256 from ${CACHE_ROOT}/${base_name}.tar.gz.sha256"
            package_sha256="$(< "${CACHE_ROOT}/${base_name}.tar.gz.sha256")"
            rm "${CACHE_ROOT}/${base_name}.tar.gz.sha256"
        fi
    else
	curl -k --remote-name --silent --show-error --fail "${DOWNLOAD_URL}/${base_name}.tar.gz"
    fi
    if [ -n "$package_sha256" ]; then
        echo "Verifying package integrity"
        echo "$package_sha256  ${base_name}.tar.gz" | sha256sum -c - || exit "$?"
    fi
    tar xzf "${base_name}.tar.gz" --directory "${directory}"
    rm "${base_name}.tar.gz"
}
