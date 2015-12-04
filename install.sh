#!/bin/bash

echo -n "Please specify the database username to be used [ENTER]: "
read dbusername
echo -n "Please specify the database password to be used [ENTER]: "
read dbpassword

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
fi

# create s3 bucket
bucket_count=`aws s3api list-buckets | grep -c mybb-binaries`
if [ "$bucket_count" != "1" ]; then
  echo "Creating s3 bucket mybb-binaries"
  aws s3api create-bucket --acl private --bucket mybb-binaries
else
  echo "s3 bucket already exists, skipping create."
fi

# upload binary to s3 bucket
binary_count=`aws s3 ls mybb-binaries | grep -c mybb-deploy.zip`
if [ "$binary_count" != "1" ]; then
  echo "Uploading s3 binary mybb-deploy.zip"
  aws s3 cp ./mybb-deploy.zip s3://mybb-binaries/
else
  echo "binary already on s3, skipping upload."
fi

# upload template to s3 bucket
#template_count=`aws s3 ls mybb-binaries | grep -c mybb-application.template`
#if [ "$template_count" != "1" ]; then
#  echo "Uploading cloudformation template to s3"
  aws s3 cp ./resources/mybb-application.template s3://mybb-binaries/
#else
#  echo "cloudformation template already on s3, skipping upload."
#fi

# create cloudformation stack
stack_id=`aws cloudformation create-stack \
  --stack-name mershon-enterprises-mybb \
  --template-url https://mybb-binaries.s3.amazonaws.com/mybb-application.template \
  --parameters ParameterKey=DBUsername,ParameterValue="$dbusername" \
               ParameterKey=DBPassword,ParameterValue="$dbpassword" \
  --query 'StackId' --output text`
rds_id=`aws cloudformation describe-stack-resources \
  --stack-name "$stack_id" \
  --logical-resource-id "DBInstance"  \
  --query 'StackResources[0].PhysicalResourceId' --output text`
rds_url=`aws rds describe-db-instances \
  --db-instance-identifier "$rds_id"
  --query 'DBInstances[0].Endpoint.Address' --output text`
elastic_id=`aws cloudformation describe-stack-resources \
  --stack-name "$stack_id" \
  --logical-resource-id "myBBAutoScalingApplication" \
  --query 'StackResources[0].PhysicalResourceId' --output text`
elastic_url=`aws elasticbeanstalk describe-environments \
  --application-name "myBB auto-scaling" \
  --query 'Environments[0].EndpointURL' --output text`
clear

echo "***************************************************"
echo
echo -e "\033[32mYour stack is being created.\033[0m This process may take up to 10 minutes to"
echo -e "complete. When ready, please visit \033[36mhttp://$elastic_url\033[0m to configure myBB."
echo
echo "***************************************************"
echo
echo -e "\033[31mIMPORTANT:\033[0m Use the following database configuration settings:"
echo
echo "Database Type:     Postgres"
echo "Database Hostname: $rds_url"
echo "Database Name:     mybb"
echo "Table Prefix:      mybb_"
echo "Database Username: $dbusername"
echo "Database Password: $dbpassword"
echo
echo -e "\033[31mIMPORTANT:\033[0m When finished, please run ./finalize-install.sh."
echo
echo "***************************************************"
echo

# prepare resources/config.php for finalized deploy
sed -i '' "s/DB_HOST/$rds_url/"    resources/config.php
sed -i '' "s/DB_USER/$dbusername/" resources/config.php
sed -i '' "s/DB_PASS/$dbpassword/" resources/config.php
