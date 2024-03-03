# Manages authentication and re-authentication to allow 
# connection to a OneDrive account.

function Get-AuthToken {

    $config = ( [xml](Get-Content ".\config.xml") ).config

    # If there's a tokens file and it contains a refresh token
    # use this to refresh the auth token now. If there's no 
    # tokens file, the refresh token is missing, or the refresh 
    # token is invalid, we will get new tokens by reauthenticating.
    try {

        $refreshToken = ( [xml](Get-Content ".\tokens.xml" -ErrorAction Stop) ).tokens.refresh

        $tokensFileCreated = Get-NewTokens -clientId $config.clientId -clientSecret $config.clientSecret -refreshToken $refreshToken -ErrorAction Stop

    } catch {

        Write-Information "Reauthenticating user to get new tokens..."

        $tokensFileCreated = Get-NewTokens -clientId $config.clientId -clientSecret $config.clientSecret

    }

    # Re-read the tokens file and return the latest auth token
    if( !($tokensFileCreated -eq 1) ) {
        Write-Error -Message "Unable to create tokens.xml file. Exiting." -ErrorAction Stop
    }

    return ( [xml](Get-Content ".\tokens.xml" -ErrorAction Stop) ).tokens.auth

}


# Gets new Access and Refresh tokens. If a valid refresh token is
# not available, a web UI will open to authenticate the user.
function Get-NewTokens {

    param(  
        [Parameter()]
        [string]$clientId,

        [Parameter()]
        [string]$clientSecret,

        [Parameter()]
        [string]$refreshToken = $null,

        [Parameter()]
        [string]$redirectUri = "http://localhost/onedrive-search-term-sync"
    )

    $auth = Get-ODAuthentication -ClientID $clientId -AppKey $clientSecret -RefreshToken $refreshToken -RedirectURI $redirectUri -Scope "onedrive.readonly,offline_access"

    # Create a new tokens.xml file
    $xmlDocument = New-Object System.Xml.XmlDocument

    $declaration = $xmlDocument.CreateXmlDeclaration("1.0", "UTF-8", $null)
    $rootElement = $xmlDocument.CreateElement("tokens")
    $authElement = $xmlDocument.CreateElement("auth")
    $refrElement = $xmlDocument.CreateElement("refresh")

    $authElement.InnerText = $auth.access_token
    $refrElement.InnerText = $auth.refresh_token

    $rootElement.AppendChild($authElement)
    $rootElement.AppendChild($refrElement)
    $xmlDocument.AppendChild($declaration)
    $xmlDocument.AppendChild($rootElement)

    $xmlDocument.Save(".\tokens.xml")

    return 1

}

Export-ModuleMember -Function Get-AuthToken
