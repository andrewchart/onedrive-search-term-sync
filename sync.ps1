
function main {

    # Imports
    Import-Module "./modules/InitializeSyncRootFolder.psm1"

    # Read config variables
    $config = ( [xml](Get-Content config.xml) ).config

    # Create the target directory for synced files
    Initialize-SyncRootFolder($config.syncRoot)

    # Check for and install OneDrive module
    if ( !(Get-Module -ListAvailable -Name OneDrive) ) {
        Write-Host "Installing OneDrive Module..."
        Install-Module -Name OneDrive
    } 
}

main