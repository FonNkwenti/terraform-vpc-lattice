# Building an Amazon VPC Lattice network with Terraform

This project demonstrates the capabilities of Amazon VPC Lattice using Terraform. The architecture includes two consumer VPCs associated with the VPC Lattice Service Network, and two services.

## Architecture

- **Consumer VPC 1**: Contains a private AWS Lambda function.
- **Consumer VPC 2**: Contains a single EC2 instance.
- **Service 1**: An EC2 instance in an autoscaling group behind an application load balancer within a VPC.
- **Service 2**: An AWS Lambda function.

## Project Structure

The project uses a modular structure to organize the Terraform code. Each module encapsulates the logic for creating a specific resource.

- `main.tf`: Entry point of the Terraform scripts.
- `variables.tf`: Defines all the variables used in the configurations.
- `outputs.tf`: Defines all the outputs to retrieve from the configurations.
- `provider.tf`: Contains the AWS provider configuration.
- `modules`: Contains all the modules used in the project. Each module has its own directory with `main.tf`, `variables.tf`, and `outputs.tf` files.

## Getting Started

1. Install Terraform.
2. Clone this repository.
3. Update the `variables.tf` file with your AWS resource details.
4. Run `terraform init` to initialize your Terraform workspace.
5. Run `terraform apply` to create the resources on AWS.

## Contributing

Please read `CONTRIBUTING.md` for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
