variable "tenancy_ocid" {
  type        = string
  description = "Tenancy ocid that is used in the DEFAULT profile in ~/.oci/config."
}

variable "user_ocid" {
  type        = string
  description = "User ocid that is used in the DEFAULT profile in ~/.oci/config."
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint that is used in the DEFAULT profile in ~/.oci/config."
}

variable "region" {
  type        = string
  description = "Region that is used in the DEFAULT profile in ~/.oci/config."
}

variable "private_key_path" {
  type        = string
  description = "Private oci api key assigned to your oci user."
}

variable "ssh_public_key" {
  type        = string
  description = "Public key that will be uploaded to compute instances for ssh login."
}

variable "shape" {
  type        = string
  description = "The compute shape that will be used for the servers."
  default     = "VM.Standard.E2.1.Micro"
}

variable "image_ocid" {
  type        = string
  description = "The ocid of the image that will be used for the server."
  default     = "ocid1.image.oc1.iad.aaaaaaaaq7lzb7lkmbnp6zlcbgbcxnypaugvm2cymqtmpfsyd45jxub5ktha"
}
