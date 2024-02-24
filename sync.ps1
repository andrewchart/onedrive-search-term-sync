
function main {

    # Imports
    Import-Module ".\modules\InitializeSyncRootFolder.psm1"
    Import-Module ".\modules\GetAuthToken.psm1"

    # Read config variables
    $config = ( [xml](Get-Content ".\config.xml") ).config

    # Create the target directory for synced files
    Initialize-SyncRootFolder -syncRoot $config.syncRoot

    # Check for and install OneDrive module
    if ( !(Get-Module -ListAvailable -Name OneDrive) ) {
        Write-Host "Installing OneDrive Module..."
        Install-Module -Name OneDrive
    } 

    # Get an authentication token to make the API query
    $token = Get-AuthToken

    Write-Output $token

}

main