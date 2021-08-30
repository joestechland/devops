Quick Create OKE Cluster with Terraform
This works in the Resource Manager of OCI to create a VCN and OKE cluster with node pool.
   Quick Create with Terraform
 variable "tenancy_ocid" {
}
variable "compartment_ocid" {
}
variable "region" {}
provider "oci" {
  region = "${var.region}"
}
variable "cluster_name" {
    default = "cluster1"
}
variable "node_pool_ssh_public_key" {
    default = null
}
variable "cluster_kubernetes_version" {
    default = "v1.19.7"
}
variable "num_of_nodes" {
    default = 3
}
variable "node_pool_shape" {
    default = "VM.Standard.E3.Flex"
}
variable "image_id" {
    default = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaa547rmkpmvfcogqrv3oigfoodqmifton3phvl3q5cormdy43wxz4q"
}
#Create a VCN in the compartment
resource "oci_core_vcn" "oke-vcn-quick-cluster" {
    compartment_id = var.compartment_ocid
    cidr_block = "10.0.0.0/16"
    display_name = "oke-vcn-quick-${var.cluster_name}"
    dns_label = "${var.cluster_name}"
}
# This will be used in Service Gatewayß
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = [".*All.*"]
    regex  = true
} }
data "oci_identity_availability_domains" "test_availability_domains" {
    compartment_id = var.tenancy_ocid
}
# Create a NAT gateway
resource "oci_core_nat_gateway" "oke-vcn-quick-nat-gateway" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
  Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 1

       display_name = "oke-ngw-quick-${var.cluster_name}"
}
#Create a Service gateway
resource "oci_core_service_gateway" "oke-vcn-quick-service-gateway" {
    compartment_id = var.compartment_ocid
    services {
#Required
        service_id = data.oci_core_services.all_services.services[0].id
    }
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-sgw-quick-${var.cluster_name}"
}
#Create a Internet gateway
resource "oci_core_internet_gateway" "oke-vcn-quick-internet-gateway" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    enabled = true
    display_name = "oke-igw-quick-${var.cluster_name}"
}
#Create Route table - Private
resource "oci_core_route_table" "oke-vcn-quick-private-routetable" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-private-routetable-${var.cluster_name}"
    route_rules {
        network_entity_id = oci_core_nat_gateway.oke-vcn-quick-nat-gateway.id
        description = "Private route table"
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
}
    route_rules {
        network_entity_id = oci_core_service_gateway.oke-vcn-quick-service-gateway.id
        description = "Service Gateway route table"
        destination = data.oci_core_services.all_services.services[0].cidr_block
        destination_type = "SERVICE_CIDR_BLOCK"
} }
#Create Route table - Public
resource "oci_core_route_table" "oke-vcn-quick-public-routetable" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-public-routetable-${var.cluster_name}"
    route_rules {
        network_entity_id = oci_core_internet_gateway.oke-vcn-quick-internet-gateway.id
        description = "Internet Gateway route table"
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
} }
#Create sec list - k8sApiEndpoint
resource "oci_core_security_list" "oke-vcn-quick-k8s-api-sec-list" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-k8sApiEndpoint-quick-${var.cluster_name}"
egress_security_rules {
Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 2

       protocol = "6"
    destination = data.oci_core_services.all_services.services[0].cidr_block
    description = "Allow Kubernetes Control Plane to communicate with OKE"
    destination_type = "SERVICE_CIDR_BLOCK"
    stateless = false
    tcp_options {
max = 443
min = 443 }
}
egress_security_rules {
    protocol = "6"
    destination = "10.0.10.0/24"
    description = "All traffic to worker nodes"
    destination_type = "CIDR_BLOCK"
    stateless = false
}
egress_security_rules {
    protocol = "1"
    destination = "10.0.10.0/24"
    description = "Path discovery"
    destination_type = "CIDR_BLOCK"
    stateless = false
    icmp_options {
        code = 4
type = 3 }
}
ingress_security_rules {
    protocol = "6"
    source = "10.0.10.0/24"
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
max = 6443
min = 6443 }
}
ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    description = "External access to Kubernetes API endpoint"
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
max = 6443
min = 6443 }
}
ingress_security_rules {
    protocol = "6"
    source = "10.0.10.0/24"
    description = "Kubernetes worker to control plane communication"
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
max = 12250
min = 12250 }
}
ingress_security_rules {
    protocol = "1"
source = "10.0.10.0/24"
Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 3

   } }
description = "Path discovery"
source_type = "CIDR_BLOCK"
stateless = false
icmp_options {
code = 4
type = 3 }
#Create sec list - Node
resource "oci_core_security_list" "oke-vcn-quick-worker-public-sec-list" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-nodeseclist-quick-${var.cluster_name}"
    egress_security_rules {
        protocol = "all"
        destination = "10.0.10.0/24"
        description = "Allow pods on one worker node to communicate with pods on other worker nodes"
        destination_type = "CIDR_BLOCK"
        stateless = false
}
    egress_security_rules {
        protocol = "6"
        destination = "10.0.0.0/28"
        description = "Access to Kubernetes API Endpoint"
        destination_type = "CIDR_BLOCK"
        stateless = false
        tcp_options {
max = 22
min = 22 }
}
    egress_security_rules {
        protocol = "6"
        destination = "10.0.0.0/28"
        description = "Kubernetes worker to control plane communication"
        destination_type = "CIDR_BLOCK"
        stateless = false
        tcp_options {
max = 12250
min = 12250 }
}
    egress_security_rules {
        protocol = "1"
        destination = "10.0.0.0/28"
        description = "Path discovery"
        destination_type = "CIDR_BLOCK"
        stateless = false
        icmp_options {
            code = 4
type = 3 }
}
    egress_security_rules {
        protocol = "6"
        destination = data.oci_core_services.all_services.services[0].cidr_block
        description = "Allow nodes to communicate with OKE to ensure correct start-up and continued
functioning"
        destination_type = "SERVICE_CIDR_BLOCK"
        stateless = false
        tcp_options {
max = 443
Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 4

   } }
min = 443 }
egress_security_rules {
    protocol = "1"
    destination = "0.0.0.0/0"
    description = "ICMP Access from Kubernetes Control Plane"
    destination_type = "CIDR_BLOCK"
    stateless = false
    icmp_options {
code = 4
type = 3 }
}
egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
    description = "Worker Nodes access to Internet"
    destination_type = "CIDR_BLOCK"
    stateless = false
}
ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    description = "Inbound SSH traffic to worker nodes"
    source_type = "CIDR_BLOCK"
    stateless = false
    tcp_options {
max = 22
min = 22 }
}
ingress_security_rules {
    protocol = "all"
    source = "10.0.10.0/24"
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    source_type = "CIDR_BLOCK"
    stateless = false
}
ingress_security_rules {
    protocol = "all"
    source = "10.0.0.0/28"
    description = "TCP access from Kubernetes Control Plane"
    source_type = "CIDR_BLOCK"
    stateless = false
}
ingress_security_rules {
    protocol = "1"
}
source = "10.0.0.0/28"
description = "Path discovery"
source_type = "CIDR_BLOCK"
stateless = false
icmp_options {
code = 4
type = 3 }
#Create sec list - LB Seclist
resource "oci_core_security_list" "oke-vcn-quick-svclbsec-list" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-svclbseclist-quick-${var.cluster_name}"
Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 5

   }
resource "oci_core_subnet" "oke-vcn-quick-subnet-node" {
    cidr_block = "10.0.10.0/24"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-nodesubnet-quick-${var.cluster_name}"
    prohibit_public_ip_on_vnic = true
    route_table_id = oci_core_route_table.oke-vcn-quick-private-routetable.id
    security_list_ids = [oci_core_security_list.oke-vcn-quick-worker-public-sec-list.id]
}
resource "oci_core_subnet" "oke-vcn-quick-k8s-api-node" {
    cidr_block = "10.0.0.0/28"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-k8sApiEndpoint-subnet-quick-${var.cluster_name}"
    prohibit_public_ip_on_vnic = false
    route_table_id = oci_core_route_table.oke-vcn-quick-public-routetable.id
    security_list_ids = [oci_core_security_list.oke-vcn-quick-k8s-api-sec-list.id]
}
resource "oci_core_subnet" "oke-vcn-quick-svclbsubnet" {
    cidr_block = "10.0.20.0/24"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    display_name = "oke-svclbsubnet-quick-${var.cluster_name}"
    prohibit_public_ip_on_vnic = false
    route_table_id = oci_core_route_table.oke-vcn-quick-public-routetable.id
    security_list_ids = [ oci_core_security_list.oke-vcn-quick-svclbsec-list.id ]
}
resource "oci_containerengine_cluster" "oke-quick-cluster" {
    compartment_id = var.compartment_ocid
    kubernetes_version = var.cluster_kubernetes_version
    name = var.cluster_name
    vcn_id = oci_core_vcn.oke-vcn-quick-cluster.id
    endpoint_config {
        is_public_ip_enabled = true
        subnet_id = oci_core_subnet.oke-vcn-quick-k8s-api-node.id
    }
    options {
       service_lb_subnet_ids = [ oci_core_subnet.oke-vcn-quick-svclbsubnet.id ]
       add_ons {
} }
    #TODO
    is_kubernetes_dashboard_enabled = true
    is_tiller_enabled = true
}
kubernetes_network_config {
    pods_cidr = "10.244.0.0/16"
    services_cidr = "10.96.0.0/16"
}
resource "oci_containerengine_node_pool" "oke-quick-cluster-node-pool" {
    cluster_id = oci_containerengine_cluster.oke-quick-cluster.id
    compartment_id = var.compartment_ocid
    kubernetes_version = var.cluster_kubernetes_version
    name = "pool1"
    node_shape = var.node_pool_shape
    node_config_details {
        placement_configs {
            availability_domain = data.oci_identity_availability_domains.test_availability_domains.
availability_domains[0]["name"]
subnet_id = oci_core_subnet.oke-vcn-quick-subnet-node.id
Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 6

   }
        size = var.num_of_nodes
    }
    node_shape_config {
        memory_in_gbs = 8
        ocpus = 1
    }
    node_source_details {
        image_id = var.image_id
        source_type = "IMAGE"
    }
    ssh_public_key = var.node_pool_ssh_public_key
}
 Content on these Oracle Cloud Infrastructure pages is classified Confidential-Oracle Internal and is intended to support Oracle internal customers & partners only using Oracle Cloud Infrastructure.
Page: 7
