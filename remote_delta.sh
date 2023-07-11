#!/usr/bin/env bash
# Author - Deb Jena
# Set the source and destination directories
src_dir="/tmp/to_transfer"
dest_dir="/storage/backup-wl/delta_remote"

# log file
log_file="/var/log/delta_file_transfer.log"

# exit immediately if any command fails
set -e

# loop through all the files in the source directory
for file in "$src_dir"/*.zip; do

  # get MD5 checksum of file
  file_md5=$(md5sum "$file" | cut -d ' ' -f 1)

  # get MD5 checksum from file's .md5 file
  file_md5_from_file=$(cat "$file.md5")

  # compare the two MD5 checksums
  if [[ $file_md5 == $file_md5_from_file ]]; then

    # The file has not changed, so move it to the destination directory
    echo "Moving file $file to $dest_dir" >> "$log_file"
    mv "$file" "$dest_dir"

  else

    # The file has not changed, input logs
    echo "File $file MD5 check not passed" >> "$log_file"

  fi
done

# clear tmp after execution
sudo rm -rf "$src_dir"
