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

if [ -f "mybb-deploy.zip" ]; then
  echo "deploy binary already present, skipping bundle."
else
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

  echo "Bundling for deployment"
  zip -q -r ../mybb-deploy.zip ./*
  cd ..
  rm -rf mybb
fi

bucket_count=`aws s3api list-buckets | grep -c mybb-binaries`
if [ "$bucket_count" != "1" ]; then
  echo "Creating s3 bucket mybb-binaries"
  aws s3api create-bucket --acl private --bucket mybb-binaries
else
  echo "s3 bucket already exists, skipping create."
fi
binary_count=`aws s3 ls mybb-binaries | grep -c mybb-deploy.zip`
if [ "$binary_count" != "1" ]; then
  echo "Uploading s3 binary mybb-deploy.zip"
  aws s3 cp ./mybb-deploy.zip s3://mybb-binaries/
else
  echo "s3 binary already exists, skipping upload."
fi
