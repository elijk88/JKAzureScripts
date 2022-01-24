#Opens a separate login window
Login-AzAccount

#Variable for resource group, Web app service plan, Website name, and location of webpage
$RgName = 'JK-RG'
$Webapp = 'JkWebApp'
$WebSiteName = 'JKWebpage'
$Location = 'East US'

#Create resource group
New-AzResourceGroup -Name $RgName -Location $Location

#Create Web app service plan and determine pricing tier level
New-AzAppServicePlan -Name $Webapp -Location $Location -ResourceGroupName $RgName -Tier Free

#Create the webpage
New-AzWebApp -Name $WebSiteName -Location $Location -AppServicePlan $Webapp -ResourceGroupName $RgName