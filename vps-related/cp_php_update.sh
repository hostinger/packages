#!/bin/bash

upload_max_filesize="2G"
post_max_size="3G"

php_ini_files=$(find /usr/local/lsws/ -type f -name "php.ini")

for php_ini in $php_ini_files; do
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = $upload_max_filesize/" $php_ini
    sed -i "s/post_max_size = .*/post_max_size = $post_max_size/" $php_ini
done
