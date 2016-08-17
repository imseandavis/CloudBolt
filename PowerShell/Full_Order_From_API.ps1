#By: Sean Davis
#Date: 11-21-2015

#Init Variables
$CloudBoltIP = "1.2.3.4" #Cloudbolt Server IP
$Environment = 1 #Get From URL By Clicking Environment Name On The Environments Page
$GroupNumber = 1 #Get From URL By Clicking Group Name On The Groups Page
$OSBuild = 1 #Get From URL By Clicking Group Name On The OSBuild Page
$RequestingUser = 1 #Get From URL By Clicking User In Admin Portal
$ApprovingUser = 1 #Get From URL By Clicking User In Admin Portal
$HostName = "SERVERNAME" #ServerName

#Build Credential
$UserName = "CloudBoltAPI"
$Password = "API" | ConvertTo-SecureString -asPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($UserName,$Password)

#Ignore SSL Certs
add-type @"
  using System.Net;
  using System.Security.Cryptography.X509Certificates;
  public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
      ServicePoint srvPoint, X509Certificate certificate,
      WebRequest request, int certificateProblem) {
        return true;
      }
  }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#Create An Order
try
{
  $GroupJSON = '{"group": "/api/v2/groups/' + $GroupNumber + '", "owner": "/api/v2/users/' + $RequestingUser + '"}'
  $Order_RequestURL = "https://$CloudBoltIP/api/v2/orders/"
  $Order = Invoke-RestMethod -Credential $Credential -Method POST -ContentType "application/json" -URI $Order_RequestURL -Body $GroupJSON
  $OrderNumber = $Order._links.self.href.Split('/')[4]
  Write-Host "Created New Order - ID: $OrderNumber"
}
catch
{
  Write-Host "Unable To Create Order, Check The Script."
}

#Add A Server to The Order
#These Parameters Will Vary From CloudBolt to CloudBolt
#You Can Get Your Specific Prov Dict From The API Browser By Looking at The Server Object In CB (See Docs)
try
{
  $UpdatedOrderJSON = @"
  {
    `"environment`": `"/api/v2/environments/$Environment`", 
    `"attributes`": {
                    `"hostname`": `"$($HostName.ToLower())`"
    }, 
    `"parameters`": {
                    `"Function`": `"FUNCTION`", 
                    `"initial_linux_password`": `"*********`", 
                    `"sc_nic_0`": `"NICNAME`", 
                    `"Workgroup`": `"WRK`", 
                    `"node_location`": `"us-east1-c`", 
                    `"node_size`": `"f1-micro`", 
                    `"Datacenter_Code`": `"DC1`", 
                    `"Tier`": `"Production`"
    }, 
    "os-build": "/api/v2/os-builds/$OSBuild"
  }
"@
  $UpdatedOrder_RequestURL = "https://$CloudBoltIP/api/v2/orders/$OrderNumber/prov-items/"
  $UpdatedOrder = Invoke-RestMethod -Credential $Credential -Method POST -ContentType "application/json" -URI $UpdatedOrder_RequestURL -Body $UpdatedOrderJSON
  Write-Host "Sucessfully Updated Order ID: $OrderNumber"
}
catch
{
  #Prov Items Are Probably Wrong, Let The User Know
  Write-Host "Unable To Create Order, This Is Most Likely Due To Missing Or Incorrect Prov Items."
}

#Submit The Order
try
{
  $SubmitOrder_RequestURL = "https://$CloudBoltIP/api/v2/orders/$OrderNumber/actions/submit/"
  $SubmitOrder = Invoke-RestMethod -Credential $Credential -Method POST -URI $SubmitOrder_RequestURL
  Write-Host "Sucessfully Submitted Order ID: $OrderNumber"
}
catch
{
  #Usually Due To Incorrect JSON Format Or Missing Mandatory Fields In JSON
  Write-Host "Unable To Create Order, Check The Script."
}

#Approve The Order If Auto Approval Isn't Set
#NOTE: You Will Be Required To Have Approver Rights To Do This Or This Will Fail!
try
{
  $ApproveOrder_RequestURL = "https://$CloudBoltIP/api/v2/orders/$OrderNumber/actions/approve/"
  $ApproveOrder = Invoke-RestMethod -Credential $Credential -Method POST -URI $ApproveOrder_RequestURL
  Write-Host "Sucessfully Approved Order ID: $OrderNumber"
}
catch
{
  Write-Host "Unable To Approve Order, Manual Approval Will Need To Be Completed Or User Doesn't Have Approver Rights."
}

#Check The Order Status
$OrderStatus = "ACTIVE"
Do
{
  Write-Host "Order Still Processing..."
  Sleep 10

  #Go Grab The Status Of The Order
  $Order_RequestURL = "https://$CloudBoltIP/api/v2/orders/$OrderNumber/"
  $Order = Invoke-RestMethod -Credential $Credential -Method GET -URI $Order_RequestURL
  $OrderStatus = $($Order.Status)
}
While ($OrderStatus -eq "ACTIVE")

#Update The User The Job Is Done
Write-Host "Order Has Been Completed And Returned The Status: $OrderStatus"
