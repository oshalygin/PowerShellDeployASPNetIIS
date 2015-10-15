Import-Module WebAdministration

Set-Location IIS:

$siteName = "SolutionPub"
$appPoolName = $siteName
$protocol = "http"
$port = "9941"
$projectPath = "C:\dev\SolutionPub\"
$binding = "*:" + $port + ":"

Write-Host -ForegroundColor DarkGreen "Deploying $siteName to local IIS"


If(Get-Item IIS:\AppPools\$appPoolName -EA 0){
    Write-Host -ForegroundColor DarkRed "$appPoolName ApplicationPool already Exists, Skipping..."
}
Else {
    New-Item IIS:\AppPools\$appPoolName
}

If(Get-Item IIS:\Sites\$siteName -EA 0) {
    Write-Host -ForegroundColor DarkRed "$siteName Site already Exists, Skipping..."
}
Else {
    New-Item IIS:\Sites\$siteName -bindings @{protocol=$protocol;bindingInformation=$binding} -physicalPath $projectPath -applicationPool $appPoolName
}

Write-Host -ForegroundColor DarkGreen "Restarting IIS, W3SVC and WAS(Windows Activation Services)"

    IISRESET /Restart
    Restart-Service W3SVC,WAS -Force


    Write-Host -ForegroundColor DarkGreen "Enabling Anonymous Authentication"
    Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value True
    Write-Host -ForegroundColor DarkGreen "Enabled Anonymous Authentication"
