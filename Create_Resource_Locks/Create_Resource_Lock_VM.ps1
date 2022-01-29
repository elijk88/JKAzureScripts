Create_Resource_Lock_VM

#When I intially ran this code, it created the VM without the resource lock.
#I got an error and I wanted to run this code without errors. So, I had to created
#the resource group and VM. After running the below code, it ran without errors.
#To run this script first connect to your Azure account. Dependenices: Resource.
#Group and VM


$RSLock =@{
	
    ResourceGroupName = 'JK-RG'
    ResourceName = 'TestVM1'
    ResourceType = 'Microsoft.Compute/virtualMachines'
    LockLevel = 'CanNotDelete' #Level can be Readonly or CanNotDelete
    LockName ='DeleteLock'
	Force = $true
}

New-AzResourceLock @RSLock

#Checking to ensure lock was created in Azure
Get-AzResourceLock | Select-Object Name,ResourceName,Properties 

#Remove resource lock
Get-AzResourceLock | Out-GridView -PassThru | Remove-AzResourceLock -Force
Remove-AzVM -ResourceGroupName 'JK-RG' -Name 'TestVM1' -Confirm
Remove-AzVirtualNetwork -Name 'JK-RG-vnet' -ResourceGroupName 'JK-RG' 
Remove-AzureVirtualIP -VirtualIPName 'TestVM1-ip'

