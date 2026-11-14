#!/bin/bash
# lib.sh - helper functions for auditor.sh

LOG_FILE="auditor.log"

# print a normal message
log_info() {
    echo "[INFO] $*"
}

# print an error message
log_error() {
    echo "[ERROR] $*" >&2
}

# write one line to the log file with date and time
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

# stop the script if the folder does not exist
require_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        log_error "folder $dir does not exist"
        exit 1
    fi
}
