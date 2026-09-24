mock_provider "aws" {
}

run "rejects_auto_accept_with_peer_region" {
  command = plan

  variables {
    vpc_id      = "vpc-0123456789abcdef0"
    peer_vpc_id = "vpc-0fedcba9876543210"
    peer_region = "eu-west-1"
    auto_accept = true
  }

  expect_failures = [var.auto_accept]
}

run "rejects_auto_accept_with_peer_owner_id" {
  command = plan

  variables {
    vpc_id        = "vpc-0123456789abcdef0"
    peer_vpc_id   = "vpc-0fedcba9876543210"
    peer_owner_id = "123456789012"
    auto_accept   = true
  }

  expect_failures = [var.auto_accept]
}

run "required_arguments_pass_through" {
  command = plan

  variables {
    vpc_id      = "vpc-0123456789abcdef0"
    peer_vpc_id = "vpc-0fedcba9876543210"
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.vpc_id == "vpc-0123456789abcdef0"
    error_message = "vpc_id should pass through unchanged."
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.peer_vpc_id == "vpc-0fedcba9876543210"
    error_message = "peer_vpc_id should pass through unchanged."
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.auto_accept == false
    error_message = "auto_accept should default to false, matching AWS's own default and the safe same-account/same-region-only constraint."
  }

  assert {
    condition     = length(aws_vpc_peering_connection.resource.requester) == 0
    error_message = "allow_remote_vpc_dns_resolution was not set, so no requester block should be rendered."
  }
}

run "cross_region_and_cross_account_fields_pass_through" {
  command = plan

  variables {
    vpc_id        = "vpc-0123456789abcdef0"
    peer_vpc_id   = "vpc-0fedcba9876543210"
    peer_region   = "eu-west-1"
    peer_owner_id = "123456789012"
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.peer_region == "eu-west-1"
    error_message = "peer_region should pass through unchanged."
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.peer_owner_id == "123456789012"
    error_message = "peer_owner_id should pass through unchanged."
  }
}

run "allow_remote_vpc_dns_resolution_renders_requester_block" {
  command = plan

  variables {
    vpc_id                          = "vpc-0123456789abcdef0"
    peer_vpc_id                     = "vpc-0fedcba9876543210"
    allow_remote_vpc_dns_resolution = true
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.requester[0].allow_remote_vpc_dns_resolution == true
    error_message = "allow_remote_vpc_dns_resolution = true should render a requester block with the same value."
  }
}

run "readme_same_account_example" {
  command = plan

  variables {
    vpc_id      = "vpc-0123456789abcdef0"
    peer_vpc_id = "vpc-0fedcba9876543210"
    auto_accept = true
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.auto_accept == true
    error_message = "The README's same-account example should set auto_accept = true."
  }
}

run "readme_cross_region_example" {
  command = plan

  variables {
    vpc_id      = "vpc-0123456789abcdef0"
    peer_vpc_id = "vpc-0fedcba9876543210"
    peer_region = "eu-west-1"
  }

  assert {
    condition     = aws_vpc_peering_connection.resource.auto_accept == false
    error_message = "The README's cross-region example should leave auto_accept at its false default, pairing with the accepter module instead."
  }
}
