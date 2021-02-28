# Valheim Backup Script
# for local Valheim installation on Windows

# Makes a time-stamped compressed archive of the Valheim game data folder, 
# (which includes player characters and local worlds),
# and saves it into a backup folder in the user Documents folder.

# TODO : Automate removal of old or excess archives.
# Manual cleanup of old archives is required for now.

$TimeDateStamp = Get-Date -Format yyyy-MM-dd-HHmm
$SourcePath = "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\*"
$BackupPath = "$env:USERPROFILE\Documents"
$BackupDirName = "ValheimBackup"
$ThisBackupName = "Valheim-$TimeDateStamp"

Write-Output "Backing up files:`n$SourcePath`n"

Write-Output "Checking for backup directory...`n$BackupPath\$BackupDirName`n"
if ( -Not (Test-Path "$BackupPath\$BackupDirName")) {
	Write-Output "Creating backup directory.`n"
	$NewParams = @{
		Path = "$BackupPath"
		Name = "$BackupDirName"
		ItemType = "directory"
	}
	New-Item @NewParams | Out-Null
}

Write-Output "Checking for recent backup...`n$ThisBackupName.zip`n"
if ( -Not (Test-Path "$BackupPath\$BackupDirName\$ThisBackupName.zip" )) {
	Write-Output "Creating new backup...`n"
	$NewParams = @{
		Path = "$BackupPath\$BackupDirName"
		Name = "$ThisBackupName"
		ItemType = "directory"
	}
	New-Item @NewParams | Out-Null
	
	Write-Output "Copying files...`n"
	$CopyParams = @{
		Path = "$SourcePath"
		Destination = "$BackupPath\$BackupDirName\$ThisBackupName"
		Force = $True
		Recurse = $True
	}
	Copy-Item @CopyParams
	
	Write-Output "Compressing files...`n"
	$CompressParams = @{
		Path = "$BackupPath\$BackupDirName\$ThisBackupName\*"
		DestinationPath = "$BackupPath\$BackupDirName\$ThisBackupName.zip"
	}
	Compress-Archive @CompressParams
	
	Write-Output "Cleaning up...`n"
	$RemoveParams = @{
		Path = "$BackupPath\$BackupDirName\$ThisBackupName"
		Force = $True
		Recurse = $True
	}
	Remove-Item @RemoveParams
	
	Write-Output "Backup complete.`n$BackupPath\$BackupDirName\$ThisBackupName.zip`n"
}
else {
	Write-Warning "Recent backup already exists. `nOnly one backup per minute. `nTry again later.`n"
}

Write-Output "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
