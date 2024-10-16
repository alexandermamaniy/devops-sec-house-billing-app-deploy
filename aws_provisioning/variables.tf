# List of cidr blocks
variable "cidr_blocks" {
  type        = list(string)
  description = "cidr blocks definition"
}

# Remote IP address for SSH access
variable "remoteip" {
  type        = string
  description = "Remote admin IP address"
  default     = ""
}

