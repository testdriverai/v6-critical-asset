# Google Drive file ID from the shared link
          $fileId = "1G-FEUF9AoC8cw6O1DwZSfcHl6peZDuHz"

          # Construct the download URL
          $downloadUrl = "https://drive.google.com/uc?export=download&id=$fileId"

          # Create a web request
          $response = Invoke-WebRequest -Uri $downloadUrl -Method Get -MaximumRedirection 0 -ErrorAction SilentlyContinue

          # If redirected, follow to actual download URL
          if ($response.StatusCode -eq 302) {
              $redirectUrl = $response.Headers['Location']

              # Get redirected content to extract filename
              $finalResponse = Invoke-WebRequest -Uri $redirectUrl -Method Get -Headers @{ "User-Agent" = "Mozilla/5.0" }

              # Extract original filename from Content-Disposition header
              $contentDisposition = $finalResponse.Headers.'Content-Disposition'
              if ($contentDisposition -match 'filename\*?=.*?\'\'(?<filename>.+)$') {
                  $fileName = [System.Net.WebUtility]::UrlDecode($matches['filename'])
              } elseif ($contentDisposition -match 'filename="?([^"]+)"?') {
                  $fileName = $matches[1]
              } else {
                  $fileName = "downloaded_file"
              }

              # Get Desktop path (or whatever path you want)
              $desktopPath = [Environment]::GetFolderPath("Desktop")
              $outputFilePath = Join-Path $desktopPath $fileName

              # Save file
              $finalResponse.Content | Set-Content -Encoding Byte -Path $outputFilePath

              Write-Output "File downloaded to: $outputFilePath"
          } else {
              Write-Error "Failed to retrieve redirect URL from Google Drive."
          }