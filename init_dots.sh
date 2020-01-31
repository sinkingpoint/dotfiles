#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
CONFIG_FILE="${SCRIPT_DIR}/config"

expand_tilde() {
    orig="${1}"
    expanded=$(echo "${orig}" | sed "s;~/;$HOME/;g")
    success=$?
    echo "${expanded}"
    return $success
}

prepare_link_to(){
    from=$(expand_tilde "${SCRIPT_DIR}/${1}")
    to=$(expand_tilde "${2}")
    if [[ -f "${to}" || -d "${to}" ]] && [[ ! -L "${to}" ]]; then
        echo "Current file is not a link. Moving ${to} to ${to}.old"
        mv "${to}" "${to}.old"
    fi

    if [[ -L "${to}" ]]; then
        current_link=$(readlink -f "${to}")
        if [[ "${current_link}" != "${from}" ]]; then
            echo "Current link points to ${current_link}. Removing it"
            rm "${to}"
        fi
    fi

    if [[ ! -f "${to}" ]]; then
        echo "Linking ${from} to ${to}"
        ln -s "${from}" "${to}"
        return 0
    fi

    return 1
}

main(){
    mapfile -t DOTFILES < "${CONFIG_FILE}"
    done_links=0
    for f in "${DOTFILES[@]}"; do
        from=$(echo "${f}" | awk '{print $1}')
        to=$(echo "${f}" | awk '{print $3}')
        if prepare_link_to "${from}" "${to}"; then
            done_links=$(bc <<< "${done_links}+1")
        fi
    done

    echo "All done. Created ${done_links} links"
}

main