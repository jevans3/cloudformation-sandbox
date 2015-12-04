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
