$port = 86
$numberOfConnectionAttempts = 5
$siteName = "DerpLord"


Function ConfirmSiteIsActive ([int]$port, [int]$numberOfAttempts) {

    $failedConnection = $true;
    For($i = 1; $i -le $numberOfAttempts) {
        $connectionState = Test-NetConnection localhost -Port $port

        If($connectionState.TcpTestSucceeded -eq "True") {
            $i = $numberOfAttempts;
            Write-Host -ForegroundColor DarkGreen "Successfully Connected to http://localhost:$port"
            $failedConnection = $false;
        }
        Else {
        Write-Host -ForegroundColor DarkRed "Could not establish a connection to http://localhost:$port.  Trying again..."
        }
        $i = $i + 1;
    }

    If($failedConnection -eq "False") {
        Write-Host -ForegroundColor DarkRed "Attempted $numberOfAttempts times and could not establish a connection to http://localhost:$port"
    }


}

$deploymentScript = {

    Param($siteName, $port)

    Import-Module WebAdministration

    Set-Location IIS:

    Write-Host $port
    Write-Host $siteName

    #$siteName = "SolutionPub"
    $appPoolName = $siteName
    $protocol = "http"
    $projectPath = "C:\dev\TechieJS\TN6\TN.Web\"
    $binding = "*:" + $port + ":"


    Write-Host -ForegroundColor DarkGreen "Deploying $siteName to local IIS"

    $appPoolExists = Test-Path IIS:\AppPools\$appPoolName
    $siteExists = Test-Path IIS:\Sites\$siteName


    If($appPoolExists -eq $false) {
        Write-Host -ForegroundColor DarkGreen "Creating ApplicationPool: $appPoolName..."
        New-Item IIS:\AppPools\$appPoolName -ea Stop
        Write-Host -ForegroundColor DarkGreen "Created ApplicationPool: $appPoolName..."
    }
    Else {
        Write-Host -ForegroundColor DarkRed "ApplicationPool: $appPoolName already exists, Skipping..."
    }


    If($siteExists -eq $false) {
        Write-Host -ForegroundColor DarkGreen "Creating WebSite: $siteName..."
        New-Item IIS:\Sites\$siteName -bindings @{protocol=$protocol;bindingInformation=$binding} -physicalPath $projectPath -applicationPool $appPoolName -ea SilentlyContinue
        Write-Host -ForegroundColor DarkGreen "Created WebSite: $siteName..."
    }
    Else {
        Write-Host -ForegroundColor DarkRed "WebSite: $siteName already exists, Skipping..."
    }

    Write-Host -ForegroundColor DarkGreen "Restarting IIS, W3SVC and WAS(Windows Activation Services)"

        IISRESET /Restart
        Restart-Service W3SVC,WAS -Force

        #Disabling Anonymous Authentication
        Write-Host -ForegroundColor DarkGreen "Disabling Anonymous Authentication"
        Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/anonymousAuthentication" -Name Enabled -Value True
        Write-Host -ForegroundColor DarkGreen "Disabled Anonymous Authentication"

        #Enabling Windows Authentication
        Write-Host -ForegroundColor DarkGreen "Enabling Windows Authentication"
        Set-WebConfigurationProperty -Filter "/system.webServer/security/authentication/windowsAuthentication" -Name Enabled -Value True
        Write-Host -ForegroundColor DarkGreen "Enabled Windows Authentication"

}

$session = New-PSSession

Invoke-Command -Session $session -ScriptBlock $deploymentScript -ArgumentList $siteName, $port

#Test the Connection to the newly created IIS WebSite
ConfirmSiteIsActive $port $numberOfConnectionAttempts