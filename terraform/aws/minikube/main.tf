provider "aws" {
  region = var.region
}

# If VPC is provided - use data objects
data "aws_vpc" "provided" {
  id    = var.vpc_id
  count = var.vpc_id != "" ? 1 : 0
}

data "aws_subnet_ids" "vpc_subnets" {
  count  = var.vpc_id != "" ? 1 : 0
  vpc_id = var.vpc_id
  tags = {
    "cluster.dev/subnet_type" = "public"
  }
}

# If VPC not provided - use default one
resource "aws_default_vpc" "default" {
  count = var.vpc_id != "" ? 0 : 1
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  count             = var.vpc_id != "" ? 0 : 1
  availability_zone = "${var.region}a"
  tags = {
    Name                      = "Default subnet for cluster.dev"
    "cluster.dev/subnet_type" = "default"
  }
}

data "template_file" "k8s_userdata" {
  template = file("k8s-userdata.tpl.sh")
  vars = {
    cluster_name = var.cluster_name
    private_key  = tls_private_key.bastion_key.private_key_pem
  }
}

module "minikube" {
  source              = "git::https://github.com/shalb/terraform-aws-minikube.git?ref=v0.1.0"
  cluster_name        = var.cluster_name
  aws_instance_type   = var.aws_instance_type
  aws_region          = var.region
  aws_subnet_id       = var.vpc_id != "" ? tolist(data.aws_subnet_ids.vpc_subnets[0].ids)[0] : aws_default_subnet.default.id
  hosted_zone         = var.hosted_zone
  additional_userdata = data.template_file.k8s_userdata.rendered
  ssh_public_key      = tls_private_key.bastion_key.public_key_openssh # generated in bastion.tf
  tags = {
    Application = var.cluster_name
    CreatedBy   = "cluster.dev"
  }

  addons = [
    "https://raw.githubusercontent.com/shalb/terraform-aws-minikube/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/shalb/terraform-aws-minikube/master/addons/metrics-server.yaml",
    "https://raw.githubusercontent.com/shalb/terraform-aws-minikube/master/addons/dashboard.yaml"
  ]

}
