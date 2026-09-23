$task = Get-ScheduledTask -TaskName 'AutoGitPush_NETPractice'
$settings = $task.Settings
$settings.DisallowStartIfOnBatteries = $false
$settings.StopIfGoingOnBatteries = $false
$settings.StartWhenAvailable = $true
$settings.RunOnlyIfNetworkAvailable = $false
$settings.ExecutionTimeLimit = 'PT1H'
$settings.MultipleInstancesPolicy = 'IgnoreNew'
Set-ScheduledTask -TaskName 'AutoGitPush_NETPractice' -Settings $settings
Write-Host 'Task settings updated successfully.'
