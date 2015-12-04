#!/bin/bash

echo "Locking configuration"
# copy config file into place
cp resources/config.php mybb/inc/config.php
chmod 666 mybb/inc/config.php

# add install lock
touch mybb/install/lock

echo "Re-bundling finalized binary for deployment"
cd mybb
zip -q -r ../mybb-deploy.zip ./*
cd ..

echo "Uploading finalized s3 binary mybb-deploy.zip"
aws s3 cp ./mybb-deploy.zip s3://mybb-binaries/

echo
echo "DONE! Please enjoy your myBB forum application."
