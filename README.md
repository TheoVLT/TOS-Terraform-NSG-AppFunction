# TOS Terraform NSG & AppFunction

![image](https://github.com/AlixBnd/TOS-CICD-Terraform/assets/137909386/a58318c9-8bb6-47aa-b476-6f00afa55f0e)

Terraform est un outil d'infrastructure en tant que code (IaC) qui permet de créer, modifier et gérer des infrastructures cloud de manière déclarative, en utilisant un langage simple et des fichiers de configuration.

# Objectif

Ce TOS a pour but de compléter les TOS vues précédement (Déploiement d'une App Service et d'une VM), par l'ajout d'un NSG à notre VM, et le déploiement d'une Azure Function.  
Notre déploiement sera effectué à l'aide d'une Pipeline Azure DevOps.  
Voir le TOS suivant pour la mise en place de cette Pipeline : https://github.com/AlixBnd/TOS-CICD-Terraform/tree/main  

# Pré-requis

 - Compréhension basique de Terraform
 - Compréhension basique d'Azure et Azure DevOps
 - Extensions Azure DevOps
	 - Azures Pipelines Terraform Task by Jason Johnson
	 - Terraform by Microsoft Labs

## Fichiers nécessaires au déploiement

Dans votre repo Azure DevOps, vous devriez avoir une architecture similaire :

📂 Terraform

↳ 📄 main.tf

↳ 📄 variables.tf

Si ce n'est pas le cas veuillez reprendre le TOS contenu dans la partie Objectif.  

## Ajout des ressources

/!\ Veillez à bien modifier/adapter les différents noms des ressources /!\  

### Ajout du NSG sur notre VM

Notre NSG (Network Security Group) sur Azure est un pare-feu virtuel qui filtre le trafic réseau entrant et sortant des ressources Azure, permettant de contrôler l'accès à ces ressources en fonction de règles de sécurité définies.  
Dans notre cas, il s'agira d'ouvrir le port 22 afin de permettre d'accéder à notre VM déployée précédement. (Dans le cas où vous n'avez pas de VM de déployée, le main.tf contient une partie pour déployer une VM).  

  ```hcl
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
```

Le premier bloc permet de définir le nom de notre ressource dans le fichier main.tf (azurerm_network_security_group), le nom de la ressource visible sur Azure (ssh_nsg sur la ligne "name"), la région qui correspond à celle définie précédemment, et le groupe de ressource défini précédemment.  

Ensuite, nous ajoutons la règle que nous nommons "allow_ssh" : 
	- priority : nous définissons l'ordre des règles (1001 par exemple)  
 	- direction : indique si la règle sera évaluée sur le trafic entrant ou sortant (Inbound car entrant)  
  	- access : indique si le trafic réseau sera autorisé ou refusé (Allow pour autoriser)  
   	- protocol : protocole réseau auquel cette règle s'applique (Tcp pour SSH)  
    	- source_port_range : port source ("*" accès depuis partout)  
     	- destination_port_range : port de destination (22 pour le SSH)  
      	- source_address_prefix : CIDR ou plage d'adresses IP source ou * pour correspondre à n'importe quelle adresse IP  
       	- destination_address_prefix : CIDR ou plage d'adresses IP de destination ou * pour correspondre à n'importe quelle adresse IP  

Ce qui donne :  

 <img width="1477" alt="image" src="https://github.com/TheoVLT/TOS-Terraform-NSG-AppFunction/assets/148872577/1578029b-5f63-4830-a4bc-152fb946c239">

### Ajout d'une Azure Function  
  ```hcl
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
```
