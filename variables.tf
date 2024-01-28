variable "allocated_storage" {
  description = "The amount of allocated storage."
  type        = number
  default     = 20
}
variable "storage_type" {
  description = "type of the storage"
  type        = string
  default     = "gp2"
}

variable "instance_class" {
  description = "The RDS instance class"
  default     = "db.t2.micro"
  type        = string
}
variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate"
  default     = "default.mysql8.0"
  type        = string
}
variable "engine_version" {
  description = "The engine version"
  default     = "8.0.34"
  type        = string
}
variable "skip_final_snapshot" {
  description = "skip snapshot"
  default     = "true"
  type        = string
}