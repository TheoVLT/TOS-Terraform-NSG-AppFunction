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

