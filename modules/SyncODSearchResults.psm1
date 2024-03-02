# Downloads the remote OneDrive files to the local sync 
# root folder and deletes any files from the local folder 
# that no longer match the remote search results. The
# remote file structure is preserved locally relative to
# the sync root folder.

function Sync-ODSearchResults {

    param(
        $AccessToken,
        $SyncRoot,
        $Results
    )

    foreach ($file in $results) {
        
        $fileId = [string]$file.id
        $fileName = [string]$file.name
        $filePath = [string]$file.parentReference.path

        if( !$fileId ) { continue }

        $oneDrivePath = $filePath.Replace("/drive/root:/","").Replace("/","\")
        $localPath = [system.uri]::UnescapeDataString("$syncRoot\$oneDrivePath")

        # Check if the file already exists using its path; skip downloading if it does
        if( Test-Path -Path "$localPath\$fileName" -PathType Leaf ) {
            Write-Host "Skipping download for $localPath\$fileName. The file already exists."
            continue
        }

        # Create the local directory if it doesn't exist
        New-Item -ItemType Directory -Force -Path $localPath | Out-Null

        Write-Host "Downloading $fileName to $localPath..."

        Get-ODItem -AccessToken $AccessToken -ElementId $fileId -LocalPath $localPath -ErrorAction Stop | Out-Null

    }

}