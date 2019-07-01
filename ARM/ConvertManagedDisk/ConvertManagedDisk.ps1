#��¼����֤
Add-AzureRmAccount -EnvironmentName AzureChinaCloud

#ѡ��ǰ����
$subscriptionName = 'SubscriptionName'
Select-AzureRmSubscription -SubscriptionName $subscriptionName

#������Դ��
$rgName = "LeiCloudService-Migrated"

#�������������
$vmName = "LeiVM01"

#����������ĸ߿����Լ�
$avSetName = 'LEI-AVBSET'

#��ø߿����Լ�
$avSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $avSetName

#���ø߿����Լ��Ĺ�����Ϊ2,
$avSet.PlatformFaultDomainCount = 2

#����
Update-AzureRmAvailabilitySet -AvailabilitySet $avSet -Sku Aligned

$avSet = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $avSetName

foreach($vmInfo in $avSet.VirtualMachinesReferences)
{
  $vm = Get-AzureRmVM -ResourceGroupName $rgName | Where-Object {$_.Id -eq $vmInfo.id}
  #��Ҫ�ڹػ���ִ��
  Stop-AzureRmVM -ResourceGroupName $rgName -Name $vm.Name -Force
  ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vm.Name
  
  #Ȼ�󿪻�
  Start-AzureRmVM -ResourceGroupName $rgName -Name $vm.Name
}


#���������鿴Managed Disk��URL������ִ�����������
foreach($vmInfo in $avSet.VirtualMachinesReferences)
{
  $vm = Get-AzureRmVM -ResourceGroupName $rgName | Where-Object {$_.Id -eq $vmInfo.id}
  #��Ҫ�ڹػ���ִ��
  Stop-AzureRmVM -ResourceGroupName $rgName -Name $vm.Name -Force
  
  $mdiskURL = Grant-AzureRmDiskAccess -ResourceGroupName $rgName -DiskName $vm.StorageProfile.OsDisk.Name -Access Read -DurationInSecond 3600
  Write-Output($mdiskURL)
  
   #Ȼ�󿪻�
  #Start-AzureRmVM -ResourceGroupName $rgName -Name $vm.Name
}
