variable "kubecountmasters" {
  default = 1
}

variable "kubecountnodes" {
  default = 2
}

variable "imagename" {
  default = centos7-gencloud20160906-image
}

data "template_file" "kube" {
    template = "${file("bootstrapkube.sh.tpl")}"
}

resource "openstack_compute_instance_v2" "master" {
  count = "${var.kubecountmasters}"
  name = "${format("kubestack-master-%02d-${var.openstack_user_name}", count.index+1)}"
  image_name = "${var.imagename}"
  availability_zone = "Temp"
  flavor_name = "x-large"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["allow_all"]
  region = "DEV"
  network {
    name = "demo"
  }
  config_drive = "true"

  user_data = "${data.template_file.kube.rendered}"
}

resource "openstack_compute_instance_v2" "node" {
  count = "${var.kubecountnodes}"
  name = "${format("kubestack-node-%02d-${var.openstack_user_name}", count.index+1)}"
  image_name = "${var.imagename}"
  availability_zone = "Temp"
  flavor_name = "x-large"
  key_pair = "${var.openstack_keypair}"
  security_groups = ["allow_all"]
  region = "DEV"
  network {
    name = "demo"
  }
  config_drive = "true"

  user_data = "${data.template_file.kube.rendered}"
}

output "masters" {
  value = "${join(",", openstack_compute_instance_v2.master.*.access_ip_v4)}"
}

output "nodes" {
  value = "${join(",", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}
