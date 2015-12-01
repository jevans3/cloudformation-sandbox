#!/bin/bash

echo "Downloading myBB software"
wget http://resources.mybb.com/downloads/mybb_1806.zip -O mybb.zip
if [ $? != "0" ]; then
    echo "Failed to download myBB software. Please try again later."
    exit 1
fi
