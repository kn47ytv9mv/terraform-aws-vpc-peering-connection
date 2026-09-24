# terraform-aws-vpc-peering-connection

Terraform module for the requester side of a VPC peering connection.

## Cost

VPC peering connections carry no charge of their own — data transferred
across one bills at AWS's standard data transfer rate (intra-region or
inter-region, depending on whether the peered VPCs are in the same
region). See AWS's
[VPC pricing](https://aws.amazon.com/vpc/pricing/) page for current
rates.

## Design

`auto_accept` lets this module accept its own peering connection in the
same apply, but only when the peer VPC is in the same AWS account and
region — AWS enforces this restriction directly. For any cross-account or
cross-region peering, leave `auto_accept` false and pair this module with
[`terraform-aws-vpc-peering-connection-accepter`](https://github.com/kn47ytv9mv/terraform-aws-vpc-peering-connection-accepter)
on the peer side, using this module's `id` output. A peering connection
stays in a `pending-acceptance` state, unusable for routing, until
accepted.

Unlike a transit gateway, a peering connection is non-transitive — it
only connects the two VPCs named in it, with no reachability through a
third. For more than a couple of VPCs, or for global reachability
across many regions,
[`terraform-aws-transit-gateway`](https://github.com/kn47ytv9mv/terraform-aws-transit-gateway)
is the better fit; this module is for the simple two-VPC case, where a
transit gateway would be unnecessary overhead.

Once accepted, each side still needs its own route pointing at the
peering connection — this module does not manage routes. Use
[`terraform-aws-vpc-route-table`](https://github.com/kn47ytv9mv/terraform-aws-vpc-route-table)'s
`vpc_peering_connection_id` route target, or `terraform-aws-vpc`'s
`custom_routes` with the same target.

## Usage

Same-account, same-region — the simple case:

```hcl
module "peering" {
  source = "kn47ytv9mv/vpc-peering-connection/aws"

  vpc_id      = module.vpc_a.vpc_id
  peer_vpc_id = module.vpc_b.vpc_id
  auto_accept = true
}
```

Or directly from this repository, for cross-region peering:

```hcl
module "peering" {
  source = "github.com/kn47ytv9mv/terraform-aws-vpc-peering-connection"

  providers = { aws = aws.us_east_1 }

  vpc_id      = module.vpc_us_east_1.vpc_id
  peer_vpc_id = module.vpc_eu_west_1.vpc_id
  peer_region = "eu-west-1"
}

module "peering_accepter" {
  source = "github.com/kn47ytv9mv/terraform-aws-vpc-peering-connection-accepter"

  providers = { aws = aws.eu_west_1 }

  vpc_peering_connection_id = module.peering.id
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.9 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| vpc_id | The ID of the requesting VPC. | `null` | no |
| peer_vpc_id | The ID of the VPC to peer with. | `null` | no |
| peer_region | Region of the VPC to peer with, for cross-region peering. If null, the peer VPC is assumed to be in this provider's own region. Cross-region peering cannot use `auto_accept` — the peer side must accept with `terraform-aws-vpc-peering-connection-accepter`. | `null` | no |
| peer_owner_id | AWS account ID that owns the peer VPC, for cross-account peering. If null, the peer VPC is assumed to be in this provider's own account. Cross-account peering cannot use `auto_accept` — the peer side must accept with `terraform-aws-vpc-peering-connection-accepter`. | `null` | no |
| auto_accept | Whether to accept the peering connection immediately, in the same apply. Only works when the peer VPC is in the same account and region as this one — leave false and pair with `terraform-aws-vpc-peering-connection-accepter` for any cross-account or cross-region peering. | `false` | no |
| allow_remote_vpc_dns_resolution | Whether this VPC resolves public DNS hostnames of instances in the peer VPC to their private IP addresses. Requires `enable_dns_hostnames` on this VPC. If null, AWS's own default (`false`) applies. | `null` | no |
| tags | A map of tags to assign to the peering connection. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the VPC peering connection. Pass this to `terraform-aws-vpc-peering-connection-accepter`'s `vpc_peering_connection_id` in the peer account or region, unless `auto_accept` is true. |
| accept_status | Status of the peering connection (e.g. `'pending-acceptance'` until accepted, `'active'` once accepted). |

## License

MIT — see [LICENSE.md](LICENSE.md).
