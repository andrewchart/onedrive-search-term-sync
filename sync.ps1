
# Read config variables
$config = ([xml](Get-Content config.xml)).config

# Create the target directory for synced files
$syncRoot = $config.syncRoot

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