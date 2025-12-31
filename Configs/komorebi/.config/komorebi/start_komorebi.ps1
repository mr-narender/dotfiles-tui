Add-Type -AssemblyName System.Windows.Forms

try {
    $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams
    $monitorCount = ($monitors | Measure-Object).Count

    if ($monitorCount -eq 2) {
        $configPath = "C:\Users\narendersingh\.config\komorebi\home\komorebi.json"
    } else {
        $configPath = "C:\Users\narendersingh\.config\komorebi\office\komorebi.json"
    }

    $komorebi = Start-Process -FilePath "C:\Users\narendersingh\.scoop\apps\komorebi\current\komorebic.exe" -ArgumentList "start", "--config=$configPath", "--whkd" -PassThru -WindowStyle Hidden

    $timeout = 10
    $elapsed = 0
    $interval = 1

    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds $interval
        $elapsed += $interval

        $komorebi.Refresh()

        if ($komorebi.ExitCode -eq 0) {
            # Start-Process "yasb" -WindowStyle Hidden
            exit 0
        }
    }

    # Komorebi failed to start
    [System.Windows.Forms.MessageBox]::Show("Komorebi failed to start within $timeout seconds.", "Startup Error", 'OK', 'Error')
    # exit 1

} catch {
    [System.Windows.Forms.MessageBox]::Show("An unexpected error occurred: $_", "Script Error", 'OK', 'Error')
    # exit 1
}
