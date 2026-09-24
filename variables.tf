variable "vpc_id" {
  default     = null
  description = "The ID of the requesting VPC."
}

variable "peer_vpc_id" {
  default     = null
  description = "The ID of the VPC to peer with."
}

variable "peer_region" {
  default     = null
  description = "Region of the VPC to peer with, for cross-region peering. If null, the peer VPC is assumed to be in this provider's own region. Cross-region peering cannot use auto_accept — the peer side must accept with terraform-aws-vpc-peering-connection-accepter."
}

variable "peer_owner_id" {
  default     = null
  description = "AWS account ID that owns the peer VPC, for cross-account peering. If null, the peer VPC is assumed to be in this provider's own account. Cross-account peering cannot use auto_accept — the peer side must accept with terraform-aws-vpc-peering-connection-accepter."
}

variable "auto_accept" {
  default     = false
  description = "Whether to accept the peering connection immediately, in the same apply. Only works when the peer VPC is in the same account and region as this one — leave false and pair with terraform-aws-vpc-peering-connection-accepter for any cross-account or cross-region peering."

  validation {
    condition     = !var.auto_accept || (var.peer_region == null && var.peer_owner_id == null)
    error_message = "auto_accept cannot be true when peer_region or peer_owner_id is set — AWS does not support same-apply acceptance for cross-region or cross-account peering. Leave auto_accept false and pair with terraform-aws-vpc-peering-connection-accepter instead."
  }
}

variable "allow_remote_vpc_dns_resolution" {
  default     = null
  description = "Whether this VPC resolves public DNS hostnames of instances in the peer VPC to their private IP addresses. Requires enable_dns_hostnames on this VPC. If null, AWS's own default (false) applies."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the peering connection."
}
