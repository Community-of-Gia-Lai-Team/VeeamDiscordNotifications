# Veeam Backup & Replication Notifications for Discord

## VeeamDiscordNotifications has been replaced by [VeeamNotify](https://github.com/tigattack/VeeamNotify).

This repository is now archived.

---

Send Veeam Backup & Replication session summary notifications to Discord, detailing session result and statistics and optionally alerting you via mention when a job finishes in a warning or failed state.

<a href="https://github.com/tigattack/VeeamDiscordNotifications/blob/master/asset/embeds.png"><img src="https://github.com/tigattack/VeeamDiscordNotifications/blob/dev/asset/embeds-small.png?raw=true" alt="Notification Example" width="90%"/></a>

## Installing

* Option 1 - Install script. This option will also optionally configure your any supported jobs to send Discord notifications.
  1. Download [Installer.ps1](Installer.ps1).
  2. Open PowerShell (as Administrator) on your Veeam server.
  3. Run the following commands:
      ```powershell
      PS> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
      PS> Unblock-File C:\path\to\Installer.ps1
      PS> C:\path\to\Installer.ps1
      ```
      <img src="https://github.com/tigattack/VeeamDiscordNotifications/blob/dev/asset/installer.png?raw=true" alt="Installer Example" width="75%"/>

* Option 2 - Manual install
  * Follow the [setup instructions](https://blog.tiga.tech/veeam-b-r-notifications-in-discord/).

### Looking for volunteers

If you enjoy this project and would like to help out, please do so. If you're interested in helping out, contact me on Discord - `tigatack#7987`

As much as I love this project, free time is hard to find and some work is needed to add functionality for more types of jobs, add more optional detail to outputs, and to bring this project in-line with recent changes in Veeam Backup & Replication (VBR) and VBR's PowerShell module.

## Supported Job Types

* VM Backup
* VM Replication
* Agent jobs managed by backup server

### Agent job caveats

Due to limitations caused by the way some types of Veeam Agent jobs are executed, only Agent jobs of type "Managed by backup server" support post-job scripts.  
Such jobs will show up as follows:
* In Veeam Backup & Replication Console, with type "Windows/Linux Agent Backup".  
If you see "Windows/Linux Agent _Policy_", this job is not supported.  
* In Veeam Backup & Replication PowerShell module, with type "EpAgentBackup".  
If you see "EpAgentPolicy", this job is not supported.  

You can read about the difference between these two Agent job types [here](https://helpcenter.veeam.com/docs/backup/agents/agent_job_protection_mode.html?ver=110#selecting-job-mode).

Unfortunately, even Agent job sessions managed by the backup server, while supported, are limited in data output.  
  As much relevant information as I've been able to discover from such job sessions is included in the Discord embed, but I welcome any suggestions for improvement in this area.

## Configuration options

Configuration can be found in `C:\VeeamScripts\VeeamDiscordNotifications\config\conf.json`

| Name                 | Type    | Required | Default           | Description                                                                                                |
|--------------------- |-------- |--------- |------------------ | ---------------------------------------------------------------------------------------------------------- |
| `webhook`            | string  | True     | null              | Your Discord webhook URL.                                                                                  |
| `thumbnail`          | string  | False    | See example above | Image URL for the thumbnail shown in the report embed.                                                     |
| `userid`             | string  | False    | null              | Your Discord user ID. Required if either of the following two options are `true`.                          |
| `mention_on_fail`    | boolean | False    | False             | When `true`, you will be mentioned when a job finishes in a failed state. Requires that `userid` is set.   |
| `mention_on_warning` | boolean | False    | False             | When `true`, you will be mentioned when a job finishes in a warning state. Requires that `userid` is set.  |
| `debug_log`          | boolean | False    | False             | When `true`, the script will log to a file in ./log/                                                       |
| `notify_update`      | boolean | False    | True              | When `true`, the script will notify (but not mention) you on Discord if there's a newer version available. |
| `self_update`        | boolean | False    | False             | When `true`, the script will update itself if there's a newer version available.                           |

---

## [Slack fork.](https://github.com/tigattack/VeeamSlackNotifications)

## [MS Teams fork.](https://github.com/tigattack/VeeamTeamsNotifications)

## Credits

[MelonSmasher](https://github.com/MelonSmasher)//[TheSageColleges](https://github.com/TheSageColleges) for [the project](https://github.com/TheSageColleges/VeeamSlackNotifications) on which this is (now loosely) based.  
[dantho281](https://github.com/dantho281) for various things - Assistance with silly little issues, the odd bugfix here and there, and the inspiration for and first works on the `Updater.ps1` script.  
[Lee_Dailey](https://reddit.com/u/Lee_Dailey) for general pointers and the [first revision](https://pastebin.com/srN5CKty) of the `ConvertTo-ByteUnit` function.  
[philenst](https://github.com/philenst) for the `DeployVeeamConfiguration.ps1` script.  
[s0yun](https://github.com/s0yun) for the `Installer.ps1` script.

Thank you all.
