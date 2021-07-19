variable "env_tag" {
  type        = string
  description = "A tag that describes the environment: dev, test or prod."
  default     = "dev"
}

variable "adls_file_systems" {
  description = "Which filesystems / containers should be created inside the ADLS?"
  type        = list(string)
  default     = ["1-landing", "2-raw", "3-clean", "4-core", "5-serve"]
}

# ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
# Databricks Variables

variable "spark_version" {
  type    = string
  default = "8.2.x-scala2.12"
}

variable "driver_node_type_id" {
  type    = string
  default = "Standard_F4s"
}

variable "node_type_id" {
  type    = string
  default = "Standard_F4s"
}
