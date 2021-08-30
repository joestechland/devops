provider "oci" {}

resource "oci_core_instance" "generated_oci_core_instance" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = "yQUJ:US-ASHBURN-AD-1"
	compartment_id = "ocid1.compartment.oc1..aaaaaaaanmfnscmt3h57fjkzp7yidagtfital3vp3oal63gcgrw2qdqkgosq"
	create_vnic_details {
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = "${oci_core_subnet.generated_oci_core_subnet.id}"
	}
	display_name = "PCNJD"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	metadata = {
		"ssh_authorized_keys" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpTJ4j3vfhfJIyY3hAtC9YP6jZZNapcyBfMtmSYZkfVSUPXF2Nq9ALw0WE/SP5gH4SZhJrZ2egvwxLSiMx4aSCZRXahshVXj+EV/J8LFfAk2wV8S/C3UdGEJGD/hN9qJg/98Z6kNcLgcbrQ69bdVFeIMKaUAH4fuBsU9vjAUuXVrtJXxGdNEsrNAUWclRY+j2NIygAlKqvLJ3glA5pP/EZj+rdEwcUvZIzFD6dDBy3XzSeAuOqcf4wedmgFg/3gCQ5lmCsI6RQb1G2+Q/UInjW/cp/vD3rWyAevBPjb/fqEyB8AZN+DX8yt4bO4jpMafL/s4OAOc0tGQupBHgUAfeN joe@JoesMBP-48.local"
	}
	shape = "VM.Standard2.2"
	source_details {
		boot_volume_size_in_gbs = "60"
		source_id = "ocid1.image.oc1..aaaaaaaasoykfuuflr4ks6zxxmj5astynromw3f523gcylgdonlwe4dbvaaq"
		source_type = "image"
	}
	depends_on = [
		oci_core_app_catalog_subscription.generated_oci_core_app_catalog_subscription
	]
}

resource "oci_core_app_catalog_subscription" "generated_oci_core_app_catalog_subscription" {
	compartment_id = "ocid1.compartment.oc1..aaaaaaaanmfnscmt3h57fjkzp7yidagtfital3vp3oal63gcgrw2qdqkgosq"
	eula_link = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.eula_link}"
	listing_id = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.listing_id}"
	listing_resource_version = "Oracle_Cloud_Developer_Image_21.01.1"
	oracle_terms_of_use_link = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.oracle_terms_of_use_link}"
	signature = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.signature}"
	time_retrieved = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.time_retrieved}"
}

resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = "10.0.0.0/16"
	compartment_id = "ocid1.compartment.oc1..aaaaaaaanmfnscmt3h57fjkzp7yidagtfital3vp3oal63gcgrw2qdqkgosq"
	display_name = "vcn-20210830-1304"
	dns_label = "vcn08301305"
}

resource "oci_core_subnet" "generated_oci_core_subnet" {
	cidr_block = "10.0.0.0/24"
	compartment_id = "ocid1.compartment.oc1..aaaaaaaanmfnscmt3h57fjkzp7yidagtfital3vp3oal63gcgrw2qdqkgosq"
	display_name = "subnet-20210830-1304"
	dns_label = "subnet08301305"
	route_table_id = "${oci_core_vcn.generated_oci_core_vcn.default_route_table_id}"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	compartment_id = "ocid1.compartment.oc1..aaaaaaaanmfnscmt3h57fjkzp7yidagtfital3vp3oal63gcgrw2qdqkgosq"
	display_name = "Internet Gateway vcn-20210830-1304"
	enabled = "true"
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = "${oci_core_internet_gateway.generated_oci_core_internet_gateway.id}"
	}
	manage_default_resource_id = "${oci_core_vcn.generated_oci_core_vcn.default_route_table_id}"
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "generated_oci_core_app_catalog_listing_resource_version_agreement" {
	listing_id = "ocid1.appcataloglisting.oc1..aaaaaaaapram7bsdh37gly4oavh42iqih6faoqqqmotpddyz4a44c4wgk7ja"
	listing_resource_version = "Oracle_Cloud_Developer_Image_21.01.1"
}
