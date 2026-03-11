#requires 
#Microsoft.Graph

$TenantId= "yourTenantIDHere"
$ClientId ="yourClientIDHere"
$ClientSecret = "yourClientSecretHere"

$ClientSecretSecure = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientId, $ClientSecretSecure
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome

$users = Get-MgUser -All

$report = @()
foreach ($user in $users) {
  $AuthMethods = Get-MgUserAuthenticationMethod -UserId $user.UserPrincipalName
  $date = Get-Date -Format "yyyy-MM-ddThh:mm:ss"
  ForEach ($entry in $AuthMethods) {
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name  "TimeStamp" -Value $date  #added so I know when this was retrieved
    $obj | Add-Member -MemberType NoteProperty -Name  "UserName" -Value $user.UserPrincipalName
    $obj | Add-Member -MemberType NoteProperty -Name Id -Value $entry.Id

    $details = $entry.AdditionalProperties
    foreach ($detail in $details.GetEnumerator()) {
      $name = "Method"
      # master list of different methods:  https://learn.microsoft.com/en-us/graph/api/resources/authenticationmethods-overview?view=graph-rest-1.0
      if ($detail.Value -eq "#microsoft.graph.emailAuthenticationMethod") {
        $value = "Email"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.externalAuthenticationMethod") {
        $value = "External"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.fido2AuthenticationMethod") {
        $value = "Fido 2 Key"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod") {
        $value = "Authenticator App"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.passwordAuthenticationMethod") {
        $value = "Password"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      #not on master list, but one I've seen, API is depricated, but still seen on user MFA
      elseif ($detail.Value -eq "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod") {
        $value = "Passwordless"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.phoneAuthenticationMethod") {
        $value = "Phone"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.platformCredentialAuthenticationMethod") {
        $value = "Platform"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.qrCodePinAuthenticationMethod") {
        $value = "QR Code Pin"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.softwareOathAuthenticationMethod") {
        $value = "TOTP Generator"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.temporaryAccessPassAuthenticationMethod") {
        $value = "Temporary Auth Pass"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      elseif ($detail.Value -eq "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod") {
        $value = "Windows Hello"
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $value
      }
      else {
        $name = $detail.Key
        $obj | Add-Member -MemberType NoteProperty -Name  $name -Value $detail.Value
      }
    }
    $report += $obj
  }
}

$date = Get-Date -Format "yyyyMMdd"
$filePath = "$($date)-MFA-Devices.json"
$report | ConvertTo-Json | Set-Content -Path $filePath 

