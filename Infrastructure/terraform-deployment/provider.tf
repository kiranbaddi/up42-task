terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"

    }
  }

  backend "azurerm" {
    resource_group_name  = "up42"
    storage_account_name = "up42tfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}


provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
