variable "name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Resource group location"
  type        = string
}

variable "tags" {
  description = "Optional resource tags"
  type        = map(string)
  default     = {}
}
