Login-AzureRmAccount -EnvironmentName AzureChinaCloud
#��¼�˻����˻��������Azure AD����ԱȨ�޵�

#ѡ����
Select-AzureRmSubscription -SubscriptionName '[��������]'| Select-AzureRmSubscription

#���Service Admin�� Co-Admin
Get-AzureRmRoleAssignment -IncludeClassicAdministrators | SELECT DisplayName,SignInName,RoleDefinitionName
