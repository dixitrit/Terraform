module "ec2_instance_module_ca-central" {
     source = "/data/.Terraform/modules/ec2_instance_module"
     region_name = var.region
     ami_value  = var.ami
     instance_type_value = "t2.micro"
     instance_count = 1
}

output "instance_public_ip_ca-central" {
   value = module.ec2_instance_module_ca-central.public-ip-address
}
