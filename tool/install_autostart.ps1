# Starts the Pawdian home server automatically when you sign in to Windows.
# It adds a shortcut to your Startup folder that runs tool\start_server.bat
# in a minimized window. Run it once:
#   powershell -ExecutionPolicy Bypass -File tool\install_autostart.ps1
# To undo, delete "Pawdian server.lnk" from the folder printed below
# (Win+R > shell:startup).
$root = Split-Path -Parent $PSScriptRoot
$startup = [Environment]::GetFolderPath('Startup')
$link = Join-Path $startup 'Pawdian server.lnk'
$shell = New-Object -ComObject WScript.Shell
$s = $shell.CreateShortcut($link)
$s.TargetPath = Join-Path $root 'tool\start_server.bat'
$s.WorkingDirectory = $root
$s.WindowStyle = 7   # minimized
$s.Description = 'Pawdian home server (web edition)'
$s.Save()
Write-Host "Added: $link"
