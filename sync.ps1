
function main {

    # Imports
    Import-Module ".\modules\InitializeSyncRootFolder.psm1"
    Import-Module ".\modules\GetAuthToken.psm1"
    Import-Module ".\modules\SyncODSearchResults.psm1"

    # Read config variables
    $config = ( [xml](Get-Content ".\config.xml") ).config

    # Create the target directory for synced files
    Initialize-SyncRootFolder -syncRoot $config.syncRoot

    # Create temporary files for diff-ing old and new results sets
    New-Item ".\currentfiles.tmp" -Force | Out-Null
    New-Item ".\latestfiles.tmp" -Force | Out-Null

    # Check for and install OneDrive module
    if ( !(Get-Module -ListAvailable -Name OneDrive) ) {
        Write-Host "Installing OneDrive Module..."
        Install-Module -Name OneDrive
    } 

    # Get an authentication token to make the API query
    $token = Get-AuthToken

    # Executes the search
    $results = Search-ODItems -AccessToken $token -SearchText $config.searchTerm -SelectProperties "id,name,parentReference"

    # Downloads the files and deletes files which no longer match
    Sync-ODSearchResults -AccessToken $token -SyncRoot $config.syncRoot -Results $results

    # Delete the temporary files
    Remove-Item ".\currentfiles.tmp"
    Remove-Item ".\latestfiles.tmp"

}

main