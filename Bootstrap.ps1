# Start logging

## Set log file name
$date = (Get-Date -UFormat %Y-%m-%d_%T | ForEach-Object { $_ -replace ":", "." })
$logFile = "$PSScriptRoot\log\Log_Bootstrap-$date.log"

## Start logging to file
Start-Transcript -Path $logFile

# Import modules.
Import-Module Veeam.Backup.PowerShell
Import-Module "$PSScriptRoot\resources\Logger.psm1"
Import-Module "$PSScriptRoot\resources\VBRSessionInfo.psm1"

# Retrieve configuration.
## Get config.
$config = Get-Content -Raw "$PSScriptRoot\config\conf.json" | ConvertFrom-Json

## Test config.
Try {
	$configSchema = Get-Content -Raw "$PSScriptRoot\config\conf.schema.json" | ConvertFrom-Json
	foreach ($i in $configSchema.required) {
		If (-not (Get-Member -InputObject $config -Name "$i" -Membertype NoteProperty)) {
			throw "Required configuration property is missing. Property: $i"
		}
	}
}
Catch {
	Write-LogMessage -Tag 'ERROR' -Message "Failed to validate configuration: $_"
}


# Stop logging and remove logfile if logging is disable in config.
If (-not $config.debug_log) {
	Stop-Logging
	Remove-Item $logFile -Force -ErrorAction SilentlyContinue
}

# Get the command line used to start the Veeam session.
$parentPID = (Get-CimInstance Win32_Process -Filter "processid='$pid'").parentprocessid.ToString()
$parentCmd = (Get-CimInstance Win32_Process -Filter "processid='$parentPID'").CommandLine

# Get the Veeam job and session IDs
$jobId = ([regex]::Matches($parentCmd, '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')).Value[0]
$sessionId = ([regex]::Matches($parentCmd, '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')).Value[1]
# Get the Veeam job details and hide warnings to mute the warning regarding deprecation of the use of this cmdlet to get Agent job details. At time of writing, there is no alternative.
$job = Get-VBRJob -WarningAction SilentlyContinue | Where-Object {$_.Id.Guid -eq $jobId}

# Get the job time
Switch ($job.JobType) {
	{$_ -eq 'Backup'} {
		$jobType = 'VM'
	}
	{$_ -eq 'EpAgentBackup'} {
		$jobType = 'Agent'
	}
}

# Get the session information and name.
$sessionInfo = Get-VBRSessionInfo -SessionID $sessionId -JobType $jobType
$jobName = $sessionInfo.JobName

Write-LogMessage -Tag 'INFO' -Message "Bootstrap script for Veeam job '$jobName' ($jobId)."

# Build argument string for the alert sender script.
$powershellArguments = "-file $PSScriptRoot\AlertSender.ps1", "-JobName $jobName", "-Id $sessionId", "-JobType $jobType", "-Config $config"

# Start a new new script in a new process with some of the information gathered here.
# This allows Veeam to finish the current session faster and allows us gather information from the completed job.
Start-Process -FilePath "powershell" -Verb runAs -ArgumentList $powershellArguments -WindowStyle hidden

# Stop logging.
If ($config.debug_log) {
	Stop-Logging
}
