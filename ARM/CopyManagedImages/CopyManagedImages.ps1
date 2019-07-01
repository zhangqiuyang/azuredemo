#�ο��ĵ���https://michaelcollier.wordpress.com/2017/05/03/copy-managed-images/

#��¼image ���ڵĶ���
Add-AzureRMAccount -Environment AzureChinaCloud

#�����޸�Ϊ��Դ����ID
$sourceSubscriptionId =  '[����ID]'

Select-AzureRmSubscription -SubscriptionId $sourceSubscriptionId

#�����޸�Ϊ��Դ���ģ���Դ������
$resourceGroupName = 'HPCPOC8'

#�����޸�Ϊ��Դ���ģ�����������������
$vmName = 'testnode0'

#�����޸�Ϊ��Դ���ģ�Դimage���ڵ�Region
$region = 'China North'

#�����޸�Ϊ��Դ���ģ�Դimage������
$imageName = 'workerImage9'

#Create a snapshot
$vm = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName

$disk = Get-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $vm.StorageProfile.OsDisk.Name

$snapshot = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $region

#snapshot name�������пո�
$regionTrim = $region.Replace(' ','')

$snapshotName = $imageName + "-" + $regionTrim + "-snapshot"

New-AzureRmSnapshot -ResourceGroupName $resourceGroupName -Snapshot $snapshot -SnapshotName $snapshotName

$snap = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName

$snapSasUrl = Grant-AzureRmSnapshotAccess -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName -DurationInSecond 3600 -Access Read
 





#Copy the snapshot to a different region for a different subscription
#��¼Ŀ�궩��
Add-AzureRMAccount -Environment AzureChinaCloud

#�����޸�Ϊ��Ŀ�궩��ID
$destSubscriptionId =  '[����ID]'

Select-AzureRmSubscription -SubscriptionId $destSubscriptionId

#�����޸�Ϊ��Ŀ�궩�ģ�Ŀ����Դ��
$destResourceGroupName = 'LeiDemo-RG'

#�����޸�Ϊ��Ŀ�궩�ĵĴ洢�˻����ơ������ֶ�����
$destStorageAccountName = 'leichinanorth'

�����޸�Ϊ��Ŀ�궩�ĵĴ洢�˻���container name������ΪСд
$destContainerName = 'private'

#�����޸ģ�Ŀ�궩�ģ��洢�˻����ڵ�Region
$destRegionName = 'China North'

$destStorageContext = (Get-AzureRmStorageAccount -ResourceGroupName $destResourceGroupName -Name $destStorageAccountName).Context

New-AzureStorageContainer -Name $destContainerName -Context $destStorageContext -Permission Off
 
$imageBlobName = $imageName + '-NEW'

# ��ʼ������ʱ��Ƚϳ�
Start-AzureStorageBlobCopy -AbsoluteUri $snapSasUrl.AccessSAS -DestContainer $destContainerName -DestContext $destStorageContext -DestBlob $imageBlobName

Get-AzureStorageBlobCopyState -Container $destContainerName -Blob $imageBlobName -Context $destStorageContext -WaitForComplete
 
# Get the full URI to the blob
$osDiskVhdUri = ($destStorageContext.BlobEndPoint + $destContainerName + "/" + $imageBlobName)

# Build up the snapshot configuration, using the Destination storage account's resource ID
$snapshotConfig = New-AzureRmSnapshotConfig -AccountType StandardLRS `
                                            -OsType Windows `
                                            -Location $destRegionName `
                                            -CreateOption Import `
                                            -SourceUri $osDiskVhdUri `
                                            -StorageAccountId "/subscriptions/${destSubscriptionId}/resourceGroups/${destResourceGroupName}/providers/Microsoft.Storage/storageAccounts/${destStorageAccountName}"

#snapshot name�������пո�
$destRegionTrim = $destRegionName.Replace(' ','')

$destSnapshotName = $imageName + "-" + $destRegionTrim + "-snap"

# Create the new snapshot in the Destination region
$destSnap = New-AzureRmSnapshot -ResourceGroupName $destResourceGroupName -SnapshotName $destSnapshotName -Snapshot $snapshotConfig



#Create an Image in Destination Subscription 
$imageConfig = New-AzureRmImageConfig -Location $destRegionName
 
Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -SnapshotId $destSnap.Id
 
New-AzureRmImage -ResourceGroupName $destResourceGroupName -ImageName $imageName -Image $imageConfig


#ִ����ϣ���Ŀ�궩�Ĵ���image�ɹ���
