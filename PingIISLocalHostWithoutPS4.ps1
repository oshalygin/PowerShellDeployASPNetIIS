Function ConfirmSiteIsActive ([int]$port, [int]$numberOfAttempts) {

    $failedConnection = $true;
    $client = New-Object System.Net.Sockets.TcpClient

    $i = 1
    While($i -le $numberOfAttempts) {
       
       Try {
            $client.Connect("localhost", $port)
            Write-Host -ForegroundColor DarkGreen "Successfully connected to http://localhost:$port"
            $i = $numberOfAttempts + 1;
            $failedConnection = $false;
       }
        Catch {
            Write-Host -ForegroundColor DarkRed "Could not establish a connection to http://localhost:$port.  Trying again..."
        
        }
        Finally {
            $i = $i + 1;
        }
       
    }

    If($failedConnection -eq "False") {
        Write-Host -ForegroundColor DarkRed "Attempted $numberOfAttempts times and could not establish a connection to http://localhost:$port"
    }


}

