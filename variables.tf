variable "name" {
  type        = string
  default     = ""
  description = "CF name"
}

variable "url" {
  type        = list(any)
  default     = [""]
  description = "CF URLs"
}

variable "cert_arn" {
  type        = string
  default     = ""
  description = "ACM Certificate"
}

variable "environment" {
  type        = string
  default     = ""
  description = "CF Environment"
}

variable "geo_restriction" {
  type        = list(any)
  default     = ["BR"]
  description = "Countries whitelist"
}