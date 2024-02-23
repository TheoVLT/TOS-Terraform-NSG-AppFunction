terraform {
  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name  = "rgmagellangptg3terraform"
    storage_account_name = "samagellangptg3dev"
    container_name       = "containerg3test"
    key                  = "tf/terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}

  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
  tenant_id       = var.ARM_TENANT_ID
  subscription_id = var.ARM_SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "test123" {
  name     = "rgmagellangptg3dev"
  location = "North Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "testserviceplan"
  resource_group_name = azurerm_resource_group.test123.name
  location            = azurerm_resource_group.test123.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "test" {
  name                = "tvvvvbestWebAp1p12345"
  resource_group_name = azurerm_resource_group.test123.name
  location            = azurerm_service_plan.test.location
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    always_on = false // Required for F1 plan (even though docs say that it defaults to false)
  }
}

# Ajout des ressources VMs

resource "azurerm_virtual_network" "vtnet_test" {
  name                = "vtnet-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test123.location
  resource_group_name = azurerm_resource_group.test123.name
}

resource "azurerm_subnet" "build_agent_subnet" {
  name                 = "build-agent"
  resource_group_name  = azurerm_resource_group.test123.name
  virtual_network_name = azurerm_virtual_network.vtnet_test.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_public_ip" "public-ip-vm-build" {
  name                = "public-ip-vm-build"
  location            = azurerm_resource_group.test123.location
  resource_group_name = azurerm_resource_group.test123.name
  sku                 = "Basic"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic-vm-agent" {
  name                = "nic-vm-agent"
  location            = azurerm_resource_group.test123.location
  resource_group_name = azurerm_resource_group.test123.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.build_agent_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip-vm-build.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-build" {
  name                            = "build-vm"
  location                        = azurerm_resource_group.test123.location
  resource_group_name             = azurerm_resource_group.test123.name
  disable_password_authentication = false
  size                            = "Standard_B1ls"
  admin_username                  = "theo"
  admin_password                  = "PrTvQr0203."
  network_interface_ids = [
    azurerm_network_interface.nic-vm-agent.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }
}

# Ajout des ressources NSG de la VM

resource "azurerm_network_security_group" "ssh_nsg" {
  name                = "ssh-nsg"
  location            = azurerm_resource_group.test123.location
  resource_group_name = azurerm_resource_group.test123.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Ajout des ressources Azure Function

resource "azurerm_storage_account" "functionapp-storage-test" {
  name                     = "storagemagellangptg3dev"
  resource_group_name      = azurerm_resource_group.test123.name
  location                 = azurerm_resource_group.test123.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test2" {
  name                = "testserviceplan2"
  resource_group_name = azurerm_resource_group.test123.name
  location            = azurerm_resource_group.test123.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_function_app" "functionapp-app-test" {
  name                = "functionappmagellangptg3dev"
  resource_group_name = azurerm_resource_group.test123.name
  location            = azurerm_resource_group.test123.location

  storage_account_name       = azurerm_storage_account.functionapp-storage-test.name
  storage_account_access_key = azurerm_storage_account.functionapp-storage-test.primary_access_key
  service_plan_id            = azurerm_service_plan.test2.id

  site_config {}
}