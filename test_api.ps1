$ErrorActionPreference = "Stop"
try {
    # $keyLine = Get-Content .env -ErrorAction Stop | Select-String "GEMINI_API_KEY"
    # if (-not $keyLine) { Write-Error "Key not found"; exit 1 }
    # $apiKey = $keyLine.ToString().Split('=')[1].Trim()
    $apiKey = "AIzaSyBs0A6QtajJPSAMfG0vtMgMadRzmq-mt-g"
    
    Write-Host "Testing with Key starting: $($apiKey.Substring(0,5))..."
    
    Write-Host "Listing Models..."
    $url = "https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey"
    
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    Write-Host "✅ Available Models:"
    foreach ($model in $response.models) {
        if ($model.name -like "*gemini*") {
            Write-Host "- $($model.name)"
        }
    }
} catch {
    Write-Host "❌ API Call Failed:"
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host "Response Body: $($reader.ReadToEnd())"
    }
}
