CloudFormation Sandbox
==

Instructions
--
1. Make sure you have AWS CLI:

  `pip install awscli`

2. Set your AWS CLI credentials:

  `aws configure`

3. Install CloudFormation template:

  `./install.sh`

  Follow the instructions to configure the app once the stack is built.

4. Finalize the configuration:

  `./finalize-install.sh`

Assumptions
--
- `zip`, `unzip`, `sed`, and `wget` commands are available

Advised, but Not Covered
--
No provision was made for CloudWatch logging beyond the ElasticBeanstalk basics.
In a production environment, CloudWatch logs would be added for monitoring the
Apache2 `access_log` and `error_log` files for errors, as well as the bash
history and SSH user login activity. Additionally, Fail2Ban would be installed
on instance startup with logical rules to ban repeated attempts at logging into
the server's internals unsuccessfully.
