# Manages the creation of a local directory which will be 
# used as the root for sync'd OneDrive files.

function Initialize-SyncRootFolder {

    param($syncRoot)

    if ( !(Test-Path -Path $syncRoot) ) {

        if( !(Test-Path -Path $syncRoot -IsValid) ) {
            Write-Error -Message "Config value for sync root directory is invalid. Exiting." -ErrorAction Stop
        }

        $createSyncRootDir = Read-Host "$syncRoot does not exist. Do you want to create it? [y/n]"

        if( $createSyncRootDir.Substring(0,1).ToLower() -eq "y" ) {
            New-Item -Path $syncRoot -ItemType "directory"
        } else {
            Write-Error -Message "Sync root directory does not exist. Exiting." -ErrorAction Stop
        }
    }

}