variable "depends_id" {
  default = ""
}

variable "command" {
  default = ":"
}

variable "command_when_destroy" {
  default = "sleep 30"
}

variable "trigger" {
  default = ""
}
