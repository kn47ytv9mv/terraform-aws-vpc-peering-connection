resource "aws_vpc_peering_connection" "resource" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  peer_owner_id = var.peer_owner_id
  auto_accept   = var.auto_accept

  dynamic "requester" {
    for_each = var.allow_remote_vpc_dns_resolution[*]

    content {
      allow_remote_vpc_dns_resolution = requester.value
    }
  }

  tags = merge(var.tags, { name = "peering" })
}

output "id" {
  description = "The ID of the VPC peering connection. Pass this to terraform-aws-vpc-peering-connection-accepter's vpc_peering_connection_id in the peer account or region, unless auto_accept is true."
  value       = aws_vpc_peering_connection.resource.id
}

output "accept_status" {
  description = "Status of the peering connection (e.g. 'pending-acceptance' until accepted, 'active' once accepted)."
  value       = aws_vpc_peering_connection.resource.accept_status
}
