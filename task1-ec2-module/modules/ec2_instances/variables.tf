variable "instances" {
  description = "Map of instances to create. Key is the logical name, value holds the per-instance config."
  type = map(object({
    instance_type    = string
    root_volume_type = string
    root_volume_size = number
    key_name         = string
    iops             = optional(number)
    protected        = optional(bool, false)
  }))

  validation {
    condition     = length(var.instances) == 5
    error_message = "Expected exactly 5 instances."
  }

  validation {
    condition = anytrue([
      for k, v in var.instances : contains(["io1", "io2"], v.root_volume_type)
    ])
    error_message = "At least one instance must use io1 or io2 storage."
  }

  validation {
    condition = alltrue([
      for k, v in var.instances :
      !contains(["io1", "io2"], v.root_volume_type) || (v.iops != null && v.iops > 0)
    ])
    error_message = "io1/io2 volumes need a positive iops value."
  }
}

variable "ami_id" {
  description = "AMI used for all instances."
  type        = string
}

variable "environment" {
  description = "Environment tag."
  type        = string
}

variable "owner" {
  description = "Owner tag."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the Name tag."
  type        = string
  default     = "arrise"
}
