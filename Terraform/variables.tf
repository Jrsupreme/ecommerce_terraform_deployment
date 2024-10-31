variable secret_key {
    type = string
    sensitive = true
}

variable access_key {
    type = string
    sensitive = true
}

variable "private_ec2_key" {
  type = string
  sensitive = true
}

variable "jenkins_pub_key" {
  type = string
}
variable region {

}

variable instance_type {
    default = "t3.micro"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "ecommercedb"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "kurac5user"
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  default     = "kurac5password"
}
