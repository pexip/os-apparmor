#!/bin/sh

set -eu

PROFILE_DIR="./etc/apparmor.d"

for f in "${PROFILE_DIR}"/*; do
    [ -f "$f" ] || continue

    # put lsb_release and nvidia_modprobe in enforce mode
    [ "$f" != "${PROFILE_DIR}/nvidia_modprobe" ] || continue
    [ "$f" != "${PROFILE_DIR}/lsb_release" ] || continue

    if grep -q --extended-regexp 'flags=\(.*\) {' "$f"; then
        # unconfined profiles don't make sense as complain
        if grep -q --fixed-strings 'flags=(unconfined)' "$f"; then
            continue
        fi

        # Deal with existing flags, but need to account for multiple
        # profiles in one file and not all of them having the same
        # flags.
        if grep -q --fixed-strings 'flags=(complain)' "$f"; then
            continue
        fi
        sed -i \
            -e 's/flags=(\(.*\)) {$/flags=(complain,\1) {/' \
            -e 's/ {$/ flags=(complain) {/' \
            -e 's/) flags=(complain) {/) {/' \
            "$f"
    else
        # No existing flags
        sed -i 's/ {$/ flags=(complain) {/' "$f"
    fi
done
