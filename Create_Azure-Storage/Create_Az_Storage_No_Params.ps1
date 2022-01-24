#Log in to Azure portal, another window will appear unless you create a variable with your credentials
#For future connections, create a variable with substruction
Login-AzAccount

#Create a resource group if there is not already one or you want to place a storage account in a new resource group
$RgName = 'JK-First-RG'
$Location = 'East US'

#Create a Storage Account if there is not one already
$StoAcctName = 'jkfirstsa02' #Select a Name for your storage Account with all lowercase characters
$StoAcctType = 'Standard_LRS' #Example storage types are Standard_B2s,Standard_A3, or
$StoAcct = New-AzStorageAccount -Name $StoAcctName -ResourceGroupName $RgName -Type $StoAcctType -Location $Location

#Create a subnet, virtual Network(vNet) and NIC Resource
$vNetName = 'JKvNet1'
$NICname = 'JKWebVm-nic'
$SubnetName = 'JKFrontSubnet'
$PublicIPName = 'JKWebVm-ip'
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix '10.0.1.0/24'

#GEt the reference to teh vNet that has the subnet being targeted
$vNet = New-AzVirtualNetwork -Name $vNetName -ResourceGroupName $RgName -Location $Location -AddressPrefix '10.0.0.0/16' -Subnet $Subnet
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vNet

#Add the Backend subnet to the vNet. In addtion, more subnets can be added to the vNet using this command
Add-AzVirtualNetworkSubnetConfig -Name BackendSubnet -VirtualNetwork $vNet -AddressPrefix '10.0.2.0/24'
Set-AzVirtualNetwork -VirtualNetwork $vNet

#Create a public IP address object that can be assigned to the NIC 
$PublicIP = New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $RgName -Location $Location -AllocationMethod Dynamic -DomainNameLabel 'jkazureconnection'

#Create the NIC attached to a subnet, with a public facing IP and private IP
$NIC = New-AzNetworkInterface -Name $NICname -ResourceGroupName $RgName -Location $Location -SubnetId $vNet.Subnets[0].id -PublicIpAddressId $PublicIP.Id -PrivateIpAddress '10.0.1.4'

#Create VM
#Now that the storage account and the network adapter are instantiated, the next step is the creation of the machine.
#However, before you can actually create the virtual machine, you must specify the configuration information. in order to do this
#you first create the configuration object that will store all the configuration information.

#Create the variable that will hold the name of the c=virtual machine
$VmName ='WebVM1'

#Create the variable that will store the sixe of the VM
$VmSize ='Standard_B1s'
#Create the virtual machine configuration object and save a reference to it
$vmConfig = New-AzVMConfig -VMName $VmName -VMSize $VmSize
 
#Now that the virtual machine configuration object is created, the configuration information can be assighed ot it. THis includes defining
#the operating system, the base gallery image, and the previously created network adapter that you want to assign to the virtual machine.
#Optionally, you can also specify a name for the operating system VHD. if you do not specify one, Azure will assign a name automatically.

#In order to define the gallery image, the publisher, offer, and the Sku for the gallery image is needed. You can reder to the following 
#article to understand how to do determine the available values to use: https://azure.microsoft.com/en-us/documentation/articles/resource-groups-vm-searching/#powershell

#For example, a Windows Server 2012R2 Datacenter image is specified in the configuration information.

$PubName = 'MicrosoftWindowsServer'
$offerName = 'WindowsServer'
$SkuName = '2012-R2-Datacenter'
$DiskName = 'WebVM1OSdisk'

#Prompt for credentials that will be used for the local admin password for the VM
$Cred = Get-Credential -Message 'Type the name and password of the local administrator account'

#Assign the operating system to the VM configuration
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $VmName -Credential $Cred -ProvisionVMAgent -EnableAutoUpdate 

#Assign the gallery image to the VM configuration
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $PubName -Offer $offerName -Skus $SkuName -Version 'latest'

#Assign the NIC to the VM configuration
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $NIC.Id

#Create the URI to store the OS disk VHD
$OSDiskURI = $StoAcct.PrimaryEndpoints.Blob.ToString()+'vhds/'+ $DiskName +'.vhd'

#Assign the OS Disk name and location to teh VM configuration
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -Name $DiskName -VhdUri $OSDiskURI -CreateOption fromImage

#With the virtual machine configuration defined, the actual virtual machine is created using the New-AzVM cmdlet
#with the configuration information passed as an argument.

New-AzVM -ResourceGroupName $RgName -Location $Location -VM $vmConfig

