#Requires -RunAsAdministrator

# Check user has webhook URL ready
$userPrompt = Read-Host -Prompt 'Do you have your Discord webhook URL ready? Y/N'

# Prompt user to create webhook first if not ready
If ($userPrompt -ne 'Y') {
	Write-Output 'Please create a Discord webhook before continuing.' `
		'Full instructions avalible at https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks'
	
	# Prompt user to launch URL
	$launchPrompt = Read-Host -Prompt 'Open URL? Y/N'
	If ($launchPrompt -eq 'Y') {
		Start-Process "https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks"
	}

	exit
}

# Prompt user with config options
$webhookUrl = Read-Host -Prompt 'Please enter your Discord webhook URL'
$mentionPreference = Read-Host -Prompt "Do you wish to be mentioned in Discord when a job fails or finishes with warnings?
	1 = No`n2 = On warn`n3 = On fail`n4 = 2 and 3`nYour choice"

If ($mentionPreference -ne 1) {
	$userId = Read-Host -Prompt 'Please enter your Discord user ID'
}

# Get latest release from GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$latestVersion = ((Invoke-WebRequest -Uri https://github.com/tigattack/VeeamDiscordNotifications/releases/latest `
	-Headers @{'Accept'='application/json'} -UseBasicParsing).Content | ConvertFrom-Json).tag_name

# Pull latest version of script from GitHub
Invoke-WebRequest -Uri `
	https://github.com/tigattack/VeeamDiscordNotifications/releases/download/$latestVersion/VeeamDiscordNotifications-$latestVersion.zip `
	-OutFile $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip

# Unblock downloaded ZIP
Unblock-File -LiteralPath $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip

# Extract release to destination path
Expand-Archive $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip -DestinationPath C:\VeeamScripts

# Rename destination and tidy up
Rename-Item C:\VeeamScripts\VeeamDiscordNotifications-$latestVersion C:\VeeamScripts\VeeamDiscordNotifications
Remove-Item $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip

# Get config
$config = Get-Content 'C:\VeeamScripts\VeeamDiscordNotifications\config\conf.json' -Raw | ConvertFrom-Json
$config.webhook = $webhookUrl

Switch ($mentionPreference) {
	1 {
		$config.mention_on_fail = 'false'
		$config.mention_on_warning = 'false'
	}
	2 {
		$config.mention_on_fail = 'false'
		$config.mention_on_warning = 'true'
		$config.userId = $userId
	}
	3 {
		$config.mention_on_fail = 'true'
		$config.mention_on_warning = 'false'
		$config.userId = $userId
	}
	4 {
		$config.mention_on_fail = 'true'
		$config.mention_on_warning = 'true'
		$config.userId = $userId
	}
}

# Write config
ConvertTo-Json $config | Set-Content C:\VeeamScripts\VeeamDiscordNotifications\config\conf.json

# Run Post Script action.
& "$PSScriptRoot\DeployPostScript.ps1"
