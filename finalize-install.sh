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

echo "Adding additional instances to environment"
template_name=`aws elasticbeanstalk describe-applications \
  --application-name "myBB auto-scaling" \
  --query 'Applications[0].ConfigurationTemplates[0]' \
  --output text`
environment_name=`aws elasticbeanstalk describe-environments \
  --application-name "myBB auto-scaling" \
  --query 'Environments[0].EnvironmentName' \
  --output text`
aws elasticbeanstalk update-configuration-template \
  --application-name "myBB auto-scaling" \
  --template-name "$template_name" \
  --option-settings "Namespace=aws:autoscaling:asg,OptionName=MinSize,Value=2" \
                    "Namespace=aws:elasticbeanstalk:application,OptionName=Application Healthcheck URL,Value=/"
aws elasticbeanstalk update-environment \
  --environment-name "$environment_name" \
  --option-settings "Namespace=aws:autoscaling:asg,OptionName=MinSize,Value=2" \
                    "Namespace=aws:elasticbeanstalk:application,OptionName=Application Healthcheck URL,Value=/"

echo
echo "DONE! Please enjoy your myBB forum application."
