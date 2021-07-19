# Azure Infrastructure as Code with Terraform

With this repository you create an infrastructure on Azure. You will create a data lake ([ADLS Gen2](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)) to store data, a databricks environment to process data with Spark and a data factory to orchestrate etl jobs. 

### Overview of the files and resources

For every resource there is a separate file. Everything related to storage is, for example, stored in the file `/src/storage.tf`. When you run the terraform commands, terraform will automatically consider every single `.tf` file. 

- __main.tf:__ Set up all Terraform providers. Create a resource group that holds the whole infrastructure.
- __active_directory.tf:__ Create [service principals](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) that can authenticate to the data lakes.
- __storage.tf:__ Create a storage account for external suppliers. They can upload all files to that storage account. Create the main data lake for all ETL processes. Create the backend for Synapse.
- __databricks.tf:__ Create the databricks workspace and two Spark clusters.
-__synapse.tf:__ Create a Synapse workspace. After you are done processing all files with Spark in databricks, you can then load the cleaned data to synapse. Synapse is based on SQL -- and offers an MPP (massively parallel processing) engine. By using Synapse you can onboard everyone in the team that knows SQL, but doesn't know Spark / Python. From there, you can create Data Marts. 
- __data_factory.tf:__ Create an Azure Data Factory resource and connect all previous resources to it.
- __locals.tf:__ Manage constant variables in this file. 

I did neither yet create the `variables.tf` file nor the `terraform.tfvars` file. You can of course create those files, too. 

### Pre conditions

Before you can use the code in src, you need to first create a remote backend. Optionally, you can also create a key vault separately. 

#### Create a remote backend

Please go to [/pre_conditions/create_remote_backend/](./pre_conditions/create_remote_backend/README.md) to first set up your remote backend. Terraform is based on a "state file". Everything you set up is going to be stored in that state file. If you are more than just one developer working on the infrastructure, you need to share that very state file. The sharing is happening in the "remote backend". If you follow the instructions, you will create a discrete resource group just to create a storage account with a container where you will eventually store your state file. 

#### Managing secrets in a key vault

If you plan on using secrets such as passwords it is advisable to use the [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/). You can find the instructions in [/pre_conditions/manage_secrets/](./pre_conditions/manage_secrets/README.md). You can create the secrets with a separate state file. That way you do not need to take care of managing secrets in the main terraform files inside `/src/`. That way you never need to worry about checking in secrets to version control, for instance. Instead, you can call every secret with a "terraform data object".

Let's make an example. Let's say that you have a password that you need to share with all the engineers. You first create a secret in Azure Key Vault. After that, you can use that secret in Terraform with the following object. That way you never need to hardcode the secret in your code. Neither will you ever need to manage environment variables. You can simply call all secrets from the Azure Key Vault. 

```hcl
# Once you have created the key vault from the outside of this code, you can
# Access all the secrets from within this code. 

# First, you call the Azure Key Vault resource.
data "azurerm_key_vault" "self" {
  name                = "advbi-key-vault-${var.env_tag}"
  resource_group_name = data.azurerm_resource_group.root.name
}

# Then, you call individual secrets from that key vault.
data "azurerm_key_vault_secret" "adls_connect_client_secret" {
  name         = "adls-connect-client-secret"
  key_vault_id = data.azurerm_key_vault.self.id
}

data "azurerm_key_vault_secret" "synapse_sql_admin_pw" {
  name         = "synapse-sql-administrator-login-password"
  key_vault_id = data.azurerm_key_vault.self.id
}
```

### How to Build the Infrastructure

Make sure that you have the [azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and the [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed. Check if you have both installed:

```zsh
# Check if you have installed the azure cli
❯ az --version
azure-cli 2.26.0 *

# Check if you have installed the terraform cli
❯ t --version
Terraform v1.0.0
```

Then, login to azure from your terminal. Execute `az login` in your command line. You will be forwarded to your browser where you can login to Azure. 

```zsh
az login
```

After you have authenticated to Azure, you can start using terraform. Make sure that you are in the `/src/` folder, and then run your terraform commands. 

```zsh
# Change directory to /src/
cd src

# Initialize terraform
terraform init

# Check your planned modifications
terraform plan

# Build your infrastructure
terraform apply
```

### Remote State

When working with terraform, it's very important to understand the concept of "state files". Terraform saves the state of the infrastructure in a state file that is usually called `terraform.tfstate`. Since multiple people work on the same infrastructure, we need to make sure that every developer has access to the very same state file. Otherwise we would have drift: The actual infrastructure would be different to what is described in the state file. Thus, we install a "remote state" by simply storing the state file in the cloud. 

Inside these storage accounts you will find the container `terraform-remote-state`. And inside that container, you will find the file `terraform.tfstate`. 

### How to manage different environments

There are generally two ways how you can manage different environments. In our case, we have three distinct environments: dev, test, prod. They are identical, though. The two ways to manage envs are:

1. workspaces (e.g. `terraform workspace new dev`)
2. directory-based

We have chosen the later option, which means that we do not use workspaces. 

Here is a great explanation of both approaches: [HashiCorp Learn: Separate Development and Production Environments](https://learn.hashicorp.com/tutorials/terraform/organize-configuration?in=terraform/modules)

### Important notes

- Never change infrastructure on the GUI / manually, but always use terraform. Otherwise, you will have drift which means that the actual environment looks different to what terraform expects.
- Only use terraform commands inside the environment directory.

### Questions

If you have questions, feel free to contact David Kuda, david.kuda@alexanderthamm.com. 