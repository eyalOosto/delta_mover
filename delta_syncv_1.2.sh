#!/bin/bash

# Author: Deb Jena

# source and destination paths for the first script
source_path_1="/storage/backup-wl/delta"
delta_backup_path="/home/user/delta_backup"
to_transfer_path="/home/user/to_transfer"

# move files to delta_backup folder and to_transfer folder
move_files() {
  mkdir -p "$delta_backup_path" || { echo "Failed to create delta_backup folder"; exit 1; }
  mkdir -p "$to_transfer_path" || { echo "Failed to create to_transfer folder"; exit 1; }
  cp "$source_path_1/"/* "$delta_backup_path"
  rsync -av --remove-source-files --exclude='*/' "$source_path_1/" "$to_transfer_path" || { echo "Failed to move files to to_transfer folder"; exit 1; }
}

# create md5 checksums in to_transfer folder
create_checksums() {
  cd "$to_transfer_path" || { echo "Failed to change directory to to_transfer folder"; exit 1; }
  for file_path in "$to_transfer_path"/*.zip; do
    md5sum=$(md5sum "$file_path" | awk '{print $1}')
    md5_file_path="${file_path}.md5"
    echo "$md5sum" > "$md5_file_path"
    echo "Created MD5 file for $file_path at $md5_file_path"
  done
}

# delete files in delta_backup older than 7 days
delete_old_files() {
  find "$delta_backup_path" -type f -mtime +7 -delete || { echo "Failed to delete old files"; exit 1; }
}

## first part execution
move_files
create_checksums
delete_old_files


# source and destination paths for the second script
destination_ip="10.1.24.90"
destination_path="/tmp/to_transfer"
remote_destination_path="/storage/backup-wl/delta_remote"
log_path="/var/log/delta_sync.log"

# create remote directory
create_remote_directory() {
    ssh "user@$destination_ip" "sudo mkdir $destination_path && sudo chmod 777 $destination_path"
}

# move files to the remote server
copy_files_remote() {
    sudo scp -rp $to_transfer_path/* "user@$destination_ip:$destination_path" || { echo "Failed to move files to the remote server"; exit 1; }
}

delete_files_to_transfer() {
    rm -rf $to_transfer_path/*
}

execute_remote_script() {
    ssh "user@$destination_ip" "sudo bash /root/remote_delta.sh"
}

## second part execution

create_remote_directory
copy_files_remote
delete_files_to_transfer
execute_remote_script
