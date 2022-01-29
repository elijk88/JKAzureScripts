function Create_WebApp {


<# 
.SYNOPSIS
This script create a basic web application

.Notes
Name: CreateWebApp
Author: JK AzureScripts
Version: 1.0
Dated Created: 

.EXAMPLE

#>	

[CmdletBinding()]
	param(
		[Parameter( Mandatory =$true)]
		[ValidateNotNullOrEmpty()]
		[string]$RgName,
		
		[Parameter( Mandatory =$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Location,
	
		[Parameter( Mandatory =$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Webapp,

		[Parameter( Mandatory =$true)]
		[ValidateNotNullOrEmpty()]
		[string]$WebSiteName
	
	)
	

#Opens a separate login window
Login-AzAccount

#Variable for resource group, Web app service plan, Website name, and location of webpage
#$RgName = 'JK-RG'
#$Webapp = 'JkWebApp'
#$WebSiteName = 'JKWebpage'
#$Location = 'East US'

#Create resource group
New-AzResourceGroup -Name $RgName -Location $Location

#Create Web app service plan and determine pricing tier level
New-AzAppServicePlan -Name $Webapp -Location $Location -ResourceGroupName $RgName -Tier Free

#Create the webpage
New-AzWebApp -Name $WebSiteName -Location $Location -AppServicePlan $Webapp -ResourceGroupName $RgName

	


}