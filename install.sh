#!/bin/bash

if [ -f "mybb.zip" ]; then
    echo "mybb.zip already present, skipping download."
else
    echo "Downloading myBB software"
    wget http://resources.mybb.com/downloads/mybb_1806.zip -O mybb.zip
    if [ $? != "0" ]; then
        echo "Failed to download myBB software. Please try again later."
        exit 1
    fi
fi

echo "Extracting and setting permissions"
unzip -q mybb.zip
rm -rf Documentation
mv Upload mybb
cd mybb
mv inc/config.default.php inc/config.php

# permissions taken from myBB installation instructions
chmod 666 inc/config.php inc/settings.php \
          inc/languages/english/*.php inc/languages/english/admin/*.php
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/ ./admin/backups/

cd ../
