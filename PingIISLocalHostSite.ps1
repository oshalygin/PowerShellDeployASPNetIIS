Function ConfirmSiteIsActive ([int]$port, [int]$numberOfAttempts) {

    $failedConnection = $true;
    For($i = 1; $i -le $numberOfAttempts) {
        $connectionState = Test-NetConnection localhost -Port $port

        If($connectionState.TcpTestSucceeded -eq "True") {
            $i = $numberOfAttempts;
            Write-Host -ForegroundColor DarkGreen "Successfully tested connection to http://localhost:$port"
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

