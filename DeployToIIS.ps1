
task DeployToLocalIIS {

    Import-Module WebAdministration

    $iisAppPoolName = "OlegAppPool"
    $iisAppPoolDotNetVersion = "v4.0"
    $iisApplicationName = "OlegSites"
        $iisApplicationName = "Oleg"
    $sitePhysicalPath = "C:\Oleg"
    $applicationPhysicalPath = "C:\Oleg\Demo\"

    Set-Location IIS:\AppPools\

    if(!(Test-Path $iisAppPoolName -pathType container )) {

        New-Item $iisAppPoolName | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
    }

    Set-Location IIS:\Sites\


    if(!(Test-Path $iisApplicationName -pathType container)) {

         $iisSite = New-Item $iisApplicationName -bindings @{protocol="http";bindingInformation=":8080:" + "Oleg"} -physicalPath $sitePhysicalPath

         $olegApplication =  $iisApplicationName 'Default Web Site'\Oleg -physicalPath $applicationPhysicalPath -type Application

        $iisSite | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName
        $olegApplication | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName
    }



}