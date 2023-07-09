#!/bin/bash

# Script written by Deb Jena

# Set source and destination paths
SOURCE="/storage/backup-wl/delta"
LOCAL_DESTINATION="/home/user/delta_backups"
REMOTE_DESTINATION="/storage/backup-wl/delta_remote"
REMOTE_SERVER="user@10.1.24.90"

# Function to copy files from source to local server
copy_files_locally() {
  mkdir -p "$LOCAL_DESTINATION"

  # Check if there are any files in the source directory
  files=$(find "$SOURCE" -maxdepth 1 -name "*.zip" -type f)
  if [[ -z "$files" ]]; then
    echo "No files found in $SOURCE. Skipping the copy operation."
    return
  fi

  rsync -av --remove-source-files "$SOURCE/"*.zip "$LOCAL_DESTINATION"
}

# Function to copy files from local to remote server
copy_files_remotely() {
  rsync -av -e ssh "$LOCAL_DESTINATION/"*.zip "$REMOTE_SERVER:$REMOTE_DESTINATION" --rsync-path="sudo rsync"
}

# Function to delete files from local destination after a specified retention period
delete_files_locally() {
  local retention_period=$1
  find "$LOCAL_DESTINATION" -name "*.zip" -type f -mtime +"$retention_period" -exec rm {} \;
}

# Call functions
copy_files_locally
copy_files_remotely
delete_files_locally 7
