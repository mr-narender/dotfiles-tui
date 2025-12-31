# get_gpu_avg_load.ps1
try {
    # Check if the web server is reachable
    $ping = Test-NetConnection -ComputerName localhost -Port 8085 -InformationLevel Quiet
    if (-not $ping) {
        throw "Could not reach Libre Hardware Monitor web server on localhost:8085."
    }

    $uri = "http://localhost:8085/data.json"
    $lhmData = Invoke-RestMethod -Uri $uri -TimeoutSec 5
    
    # Find the GPU object by its name
    $gpuObject = $lhmData.Children |
        Where-Object { $_.Text -eq "LT-TOR-17191" } |
        Select-Object -ExpandProperty Children |
        Where-Object { $_.Text -eq "Intel(R) Iris(R) Xe Graphics" }
    
    if ($null -eq $gpuObject) {
        throw "GPU object 'Intel(R) Iris(R) Xe Graphics' not found."
    }

    # Find the 'Load' sensor category under the GPU
    $loadCategory = $gpuObject.Children | Where-Object { $_.Text -eq "Load" }
    if ($null -eq $loadCategory) {
        throw "GPU 'Load' category not found."
    }

    # Extract all load sensors from the category
    $loadSensors = $loadCategory.Children | Where-Object { $_.Type -eq "Load" }
    if ($null -eq $loadSensors) {
        throw "Could not find any GPU load sensors."
    }

    # Sum all the valid load sensor values
    $totalLoad = 0
    $sensorCount = 0
    foreach ($sensor in $loadSensors) {
        # Check that the value is a number and contains "%" before processing
        if ($sensor.Value -like "* %" -and $sensor.Value -match "[\d.]+") {
            # Strip the "%" and any trailing spaces before converting to double
            $cleanValue = $sensor.Value.Replace('%', '').Trim()
            $totalLoad += [double]($cleanValue)
            $sensorCount++
        }
    }

    if ($sensorCount -gt 0) {
        $averageLoad = [math]::Round($totalLoad / $sensorCount, 1)
        Write-Output "$averageLoad %"
    } else {
        throw "No valid sensor data found for average calculation."
    }
}
catch {
    Write-Output "NA"
    Write-Error $_.Exception.Message
}
