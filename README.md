# Installing Prometheus with Terraform and Ansible

This project uses Terraform to provision a new compartment, virtual cloud network along with the related resources and two compute instances in Oracle Cloud Infrastructure. Then the project uses a local exec command in Terraform to run an Ansible playbook that will configure the observer host to run Prometheus and all the hosts to run Node Exporter.

# Installation

To run this project you will need to have [Terraform](https://developer.hashicorp.com/terraform/downloads), [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) and the [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__macos_homebrew) installed. If you don't have one, you will need to sign up for an [Oracle Cloud Infrastructure Account](https://www.oracle.com/cloud/free/). When setting up the OCI CLI you need to use an admin user and specify the ashburn region in the DEFAULT profile in `~/.oci/config`. You will also need to have an ssh keypair stored in `~/.ssh/` as `id_rsa` and `id_rsa.pub`.

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__macos_homebrew)
- [Oracle Cloud Infrastructure Account](https://www.oracle.com/cloud/free/)

# Running

Start by updating `user_setup.sh` with your Oracle Cloud Infrastructure account information that you used to configure the OCI CLI.

Change into the project directory and run the following commands in order to provision the resources and start Prometheus dashboard:

```bash
# Initialize Terraform and the OCI Provider
$ terraform init

# Export environment variables to use in Terraform
$ . ./user_setup.sh

# Review the resources Terraform will provision
$ terraform plan

# Provision the resouces in your OCI account
$ terraform apply
```

After the terraform apply is complete. Visit the `prometheus_url` link in the output to view node metrics from both servers.

Run the following command to remove all resources:

```bash
$ terraform destroy
```
