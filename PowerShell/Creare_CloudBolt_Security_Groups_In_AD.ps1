#Create CloudBolt Groups In Domain
#Naming Standard: CB-GROUPNAME-ROLE 
#By: Sean Davis
#Date: 2/23/2016

#Init Varibles
$CloudBoltOU = "DC=Corp,DC=Local" #OU You Want To Create CloudBolt Groups In
$Domain = "corp.local" #Your Domain
$Creds = Get-Credential
$GroupList = @()
$SecurityGroupDescription = "CloudBolt Security Group"

#Define Business Groups You Want To Create CloudBolt Security Groups For
$Array = @(
"GROUP1",
"GROUP2",
"GROUP3",
"ETC"
)

Loop Through Each Business Group And Create Permisisons Groups For CloudBolt To Check
ForEach($Item in $Array)
{
	$GroupList += "CB-$Item-Viewer"
	$GroupList += "CB-$Item-Requestor"
	$GroupList += "CB-$Item-Approver"
	$GroupList += "CB-$Item-ResourceAdmin"
	$GroupList += "CB-$Item-GroupAdmin"
}

#Create a CloudBolt Group In AD For Each Of The Generated Groups In The Group List
ForEach($Group in $GroupList | Select -First 1)
{
	New-ADGroup -Credential $Creds -Name $Group -SAMAccount $Group -GroupScope Global -GroupCategory Security  -DisplayName $Group.Replace("-"," ") -Path $CloudBoltOU -Description $SecurityGroupDescription
}
