data "aws_ami" "ubuntu24_image" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}



# Get the community AMI Image Id
data "aws_ami" "fck-nat-amzn2_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["fck-nat-amzn2-hvm-1.2.1-*-x86_64-ebs"]
  }
  filter {
    name   = "owner-id"
    values = ["568608671756"]
  }
}