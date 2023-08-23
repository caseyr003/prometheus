#!/bin/bash

#Enter Your Tenancy OCID
export TF_VAR_tenancy_ocid="enter_tenancy_ocid_here"
#Enter Your User OCID
export TF_VAR_user_ocid="enter_user_ocid_here"
#Enter Your Fingerprint
export TF_VAR_fingerprint="enter_fingerprint_here"
#Enter Your Region (Example: us-ashburn-1)
export TF_VAR_region="enter_region_here"
#Enter Path to Your Private OCI API Key
export TF_VAR_private_key_path="enter_private_oci_api_key_path_here"
#Enter Path to Your Public SSH Key
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)
