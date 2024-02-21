# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

#Resource group

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

#Vnet
resource "azurerm_virtual_network" "vnet" {
  name = "${var.prefix}-vnet"
  address_space = ["10.0.0.0/16"]
  location = var.location
  resource_group_name = var.resource_group_name
}

#Subnet
resource "azurerm_subnet" "subnet" {
  name = "${var.prefix}-subnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

#Public IP
resource "azurerm_public_ip" "publicip" {
  name = "${var.prefix}-publicip"
  location = var.location
  resource_group_name = var.resource_group_name
  allocation_method = "Dynamic"
}

# #Firewall
# resource "azurerm_firewall" "firewall" {
#   name = "${var.prefix}-firewall"
#   location = var.location
#   resource_group_name = var.resource_group_name
#   sku_name = "AZFW_VNet"
#   sku_tier = "Basic"
#   ip_configuration {
#     name = "internal"
#     subnet_id = azurerm_subnet.subnet.id
#     public_ip_address_id = azurerm_public_ip.publicip.id
#   }
# }

#Load balancer
resource "azurerm_lb" "lb" {
  name = "${var.prefix}-lb"
  location = var.location
  resource_group_name = var.resource_group_name
  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}