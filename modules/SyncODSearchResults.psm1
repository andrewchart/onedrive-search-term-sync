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
        $localPath = [system.uri]::UnescapeDataString("$SyncRoot\$oneDrivePath")

        # Log that this file is included in the most recent results set
        Add-Content -Path ".\latestfiles.tmp" -Value "$localPath\$fileName"

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

    Remove-DeletedObjects -SyncRoot $SyncRoot

}


# Deletes files and folders which are no longer used
function Remove-DeletedObjects {

    param(
        [Parameter()]
        [string]$SyncRoot
    )

    # Create the list of all current files in the sync root folder
    Get-ChildItem -Path $SyncRoot -Recurse -File |
    ForEach-Object {
        Add-Content -Path ".\currentfiles.tmp" -Value $_.FullName   
    }

    # Diff the current files with the latest files to determine which to delete
    $latestFiles = Get-Content(".\latestfiles.tmp")
    $currentFiles = Get-Content(".\currentfiles.tmp")

    $latestFilesHashSet = [System.Collections.Generic.HashSet[string]]::new(
        [string[]] $latestFiles,
        [System.StringComparer]::OrdinalIgnoreCase
    )

    $filesToDelete = $currentFiles.Where({
        !( $latestFilesHashSet.Contains($_) )
    })

    # Deletes the files in the sync root folder which no longer match the search term
    foreach($file in $filesToDelete) {
        Write-Host "Deleting $file as it no longer matches the OneDrive search term."
        Remove-Item $file
    }

    # Deletes subfolders of the sync root which have no files in them
    $dirsToDelete = Get-ChildItem -Path $SyncRoot -Directory -Recurse |
    Where-Object {
        (Get-ChildItem -Path $_.FullName -File -Recurse | Measure-Object).Count -eq 0
    }

    foreach($dir in $dirsToDelete) {
        Write-Host "Deleting" $dir.FullName "as it no longer contains any files."
        Remove-Item $dir.FullName -Recurse -ErrorAction SilentlyContinue
    }
    
}

Export-ModuleMember -Function Sync-ODSearchResults
