resource "null_resource" "start" {
  triggers = {
    depends_id = "${var.depends_id}"
  }
}

# terraform {
#   required_version = ">= 1.0.0, < 2.0.0"
#   required_providers {
#     ibm = {
#       source  = "ibm/ibm"
#     }
#   }
# }

locals {
  command_chomped              = "${chomp(var.command)}"
  command_when_destroy_chomped = "sleep 30"

  #command_when_destroy_chomped = "${chomp(var.command_when_destroy)}"
}

# these provide an empty file for data sources to read without exploding
resource "local_file" "stdout" {
  content  = ""
  filename = "${path.module}/stdout.${null_resource.start.id}"
}

# this overwrites local_files
resource "null_resource" "shell" {
  depends_on = ["local_file.stdout"]

  # triggers = {
  #   string = "${var.trigger}"
  # }

  provisioner "local-exec" {
    command = "sleep 600"
  }

  # provisioner "local-exec" {
  #   when       = "destroy"
  #   command    = "rm \"${path.module}/stdout.${null_resource.start.id}\""
  #   on_failure = "continue"
  # }
}

# on the first apply these will get the overridden contents
data "local_file" "stdout" {
  filename   = "${path.module}/stdout.${null_resource.start.id}"
  depends_on = ["null_resource.shell", "local_file.stdout"]
}

# first apply stores contents and then ignores the later empty contents
resource "null_resource" "contents" {
  triggers = {
    stdout = "${data.local_file.stdout.content}"
  }

  lifecycle {
    ignore_changes = [
      "triggers",
    ]
  }
}

output "stdout" {
  value = "${chomp(null_resource.contents.triggers["stdout"])}"
}
