# House Billing Deploy

The Continous Integration, Delivery and Deployment are carried out by GitHub Actions. 

This repository is executed by Continous Deployment every time that a docker image either backend or frontend is pushed and released to the main branch.


## Project Download
```
git clone https://github.com/alexandermamaniy/devops-sec-house-billing-app-deploy.git
cd devops-sec-house-billing-app-deploy/
```

### About PRODUCTION ENVIRONMENT
you must create a file named ".env.production" in the same directory of project with the environment variables for the database and set up your database configurations

```
MYSQL_DATABASE=databasename
MYSQL_USER=userdatabase
MYSQL_PASSWORD=databasepassword
MYSQL_HOST=host
MYSQL_PORT=3306
```

docker-compose -f docker-compose.production.yml up


### About Dependencies
Docker and Docker compose must be installed in your machine
```shell
sudo apt install docker docker-compose
```
### Excute the docker-compose file
```shell
docker-compose -f docker-compose.staging.yml up
```

## AWS Provisioning with Terraform

This project uses Terraform to provision AWS infrastructure, including VPC, subnets, security groups, EC2, and RDS resources.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS credentials configured in `~/.aws/credentials`
- SSH key pair available at `~/.ssh/mtckey.pub`

### Usage

1. Edit `aws_provisioning/variables.tf` to set your desired configuration (CIDR blocks, database settings, etc).
2. Initialize Terraform:
```shell
   cd aws_provisioning
   terraform init
 ```

3. Review the plan:
```shell
   terraform plan
   ```
4. Apply the configuration:
```shell
   terraform apply
   ```
5. To destroy the infrastructure when no longer needed:
```shell
   terraform destroy
   ```

