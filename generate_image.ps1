param(
    [string]$prompt,
    [string]$outputFile
)

$ErrorActionPreference = "Stop"
$apiKey = "AIzaSyBs0A6QtajJPSAMfG0vtMgMadRzmq-mt-g"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent?key=$apiKey"

$body = @{
    contents = @(
        @{
            parts = @(
                @{ text = $prompt }
            )
        }
    )
} | ConvertTo-Json -Depth 5

Write-Host "Generating image for: $outputFile"
Write-Host "Prompt: $prompt"

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    
    # Check response structure
    # Usually response.candidates[0].content.parts[0].inlineData.data (Base64)
    
    if ($response.candidates -and $response.candidates[0].content.parts[0].inlineData) {
        $base64 = $response.candidates[0].content.parts[0].inlineData.data
        $bytes = [Convert]::FromBase64String($base64)
        [System.IO.File]::WriteAllBytes($outputFile, $bytes)
        Write-Host "✅ Success! Saved to $outputFile"
    } else {
        Write-Host "❌ Error: Unexpected response format."
        Write-Host ($response | ConvertTo-Json -Depth 5)
        exit 1
    }

} catch {
    Write-Host "❌ Request Failed: $_"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host "Response Body: $($reader.ReadToEnd())"
    }
    exit 1
}
