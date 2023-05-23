# Terraform using AWS Provider on Experimental Network

Terraform is an Infrastructure as Code (IaC) software tool which can automate deployment for multiple cloud services. [Providers](https://www.terraform.io/language/providers) are plugins for Terraform to interact with cloud providers (such as AWS), SaaS and other APIs. We are using the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest) for Terraform. 

## SIEM deployment
There are currently 3 SIEMs available for deployment:
1. Splunk
2. ELK
3. No SIEM (Vanilla)

To choose the type of deployment, change the `bool` values of `is_splunk` and `is_elk` variables in [variables.tf](./variables.tf).

## Network Diagram

<kbd><img width="500" alt="experimental-network-diagram" src="https://user-images.githubusercontent.com/39242483/186832191-e591d5c9-cdbe-4427-82bc-00454380ade2.png"></kbd>

## Developer Setup

As documented in [../README.md](../README.md), you should have already set up your AWS account, AWS CLI, Terraform CLI, AWS key pairs.
1. Run `terraform init` in **this** directory. This command will download the necessary files (such as the AWS provider plugin, as specified in [main.tf](./main.tf). You only need to run this command once.

### Verifying that deployment is correct

1. After running `terraform apply`. Obtain the public IP address of the jump server in the output. If you accidentally cleared it away run `terraform output` to view the outputs again.
    

```bash
  # Your outputs for the public_ips will differ
  + WinSrv2019_private_ip = "192.168.1.50"
  + WinSrv2019_public_ip  = "13.229.65.86"
  + elk_private_ip        = "192.168.1.100"
  + elk_public_ip         = "13.213.31.203"
  + public_subnet         = "192.168.0.0/16"
  + router_private_ip     = "192.168.1.5"
  + router_public_ip      = "18.142.44.76"
    ...
```

2. You can then `ssh` into any of the machines by using your private key file (Use RDP for windows, go to the AWS console and then press `Connect` after selecting the Windows instance. Decrypt the password using the private key file and RDP into it). Run the following command:
    

```bash
    ssh -i /path/to/private/key ubuntu@<router_public_ip>
    ssh -i /path/to/private/key bitnami@<elk_public_ip>
```

## Commands

* Run `terraform fmt` to format all `.tf` files automatically. *(Please do this before committing.)*
* Run `terraform plan` to preview what resources will be added/changed/destroyed.
* Run `terraform apply` to apply the configuration.
    - You will need to type `yes` to confirm the changes.
    - Alternatively, if you are confident that your configuration is correct, you can run it with a `--auto-approve` flag. 
* Run `terraform destroy` to destroy all resources that are saved in the `terraform.tfstate` file.
    - You will need to type `yes` to confirm the changes.
    - Alternatively, if you are confident that your configuration is correct, you can run it with a `--auto-approve` flag.
* Run `terraform output` to view outputs of the deployment.

## Documentation

### `main.tf`

This file contains the main configuration for AWS resources. 

### `variables.tf`

This file contains variables such as IP address, CIDR blocks etc. Factor out variables that are *commonly* used so that we can easily change these variables in this file without having to make *multiple* same changes in the `main.tf` file.

### `outputs.tf`

This file contains outputs such as the public IP address of the jump server. These outputs are the *results* of the deployment, you can use output variables to verify that the configuration is deployed as intended. Some information such as the public IP address will not be determined after deployment is complete. The outputs will be displayed once `terraform apply` completes. You can then, for example, retrieve the public IP address of the jump server directly from the terminal instead of logging into AWS console in the browser. 

### `./setup_scripts`

This directory contains the setup scripts that will be run when instances are deployed. They are referenced in the `main.tf` file.

## Known Issues

### Bitnami ELK needs manual configuration

Certain services (Elasticsearch, Logstash) inside Bitnami ELK is hosted on `127.0.0.1` . User needs to manually `ssh` inside and change services to be hosted on `0.0.0.0` instead. Looking to resolve this in the next few commits by manually installing the ELK stack.
