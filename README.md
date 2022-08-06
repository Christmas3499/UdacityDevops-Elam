# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Install all the dependencies mentioned below

3. Export necessary variables for terraform,
   i. 'export ARM_CLIENT_ID=xxxxxxxxxxx'
   ii. 'export ARM_CLIENT_SECRET=xxxxxxxxxxxx'
   iii. 'export ARM_SUBSCRIPTION_ID=xxxxxxxxxxxx'
   iv. 'export ARM_TENANT_ID=xxxxxxxxxxxxxx'

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Use Azure CLI to log in
'az login'

2. Create and assign the policy to the subscription. Create a tagging policy with the variable tagName, so all the resources with similar tagNames are created for ease
'az policy definition create --name tagging-policy --rules tagging-policy.rules.json --params tagging-policy.params.json'

'az policy assignment create --name tagging-policy --scope '/subscriptions/7da9aa2a-dee5-47d2-8cc8-ccb1d2a68c2d' --policy tagging-policy -p "{ \"tagName\": {\"value\": \"resources\"}}"''

3. Try assignment list to visualize all the available policy assignment to the subscriptions
az policy assignment list

4. Create a packer template and build the image. The template is from server.json
packer build server.json

5. Run the infrastructure as code from terraform template. All the variables are stored in vars.tf, one can chnage if necessary. Variables like username, password, resource group, number of vms need to be created, necessary credentials, etc can be modified.
   i. Initialize the environment
       'terraform init'
   ii. Plan the environment and save the plan
       'terraform plan -out 'solution.plan 
   iii. If personal azure account is used, then infrastructure can be created
       'terraform apply'
   iv. To destroy the resources created
       'terraform destroy'
### Output
Output of policy definition and assignment can be seen in Tagging-Policy.png, output of packers can be seen in packer_output.txt and output of terraform output can be seen in terraform_output.txt

