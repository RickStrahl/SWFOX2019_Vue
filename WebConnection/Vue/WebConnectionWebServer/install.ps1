# ----------------------------------------
# Web Connection Web Server Install Script
# ----------------------------------------
# This install script adds the Web server to the Windows Path so you
# can execute `WebConnectionWebServer` from anywhere in Windows
# 
# It also checks to see that .NET Core 3.x is installed and prompts
# for installation if it is not.


# Check if the .NET SDK is installed
$ver = (dir (Get-Command dotnet).Path.Replace('dotnet.exe', 'shared\Microsoft.NETCore.App')).Name | where-object {$_.StartsWith("3.") }
if (!$ver.StartsWith("3.") )
{
    Write-Host "---------------------------------------------------------------------"
    Write-Host ".NET Core SDK 3.x is not installed. Please install the .NET Core SDK." -ForegroundColor Red
    Write-Host "---------------------------------------------------------------------"
    Write-Host "You can install the .NET Core SDK from: "
    Write-Host "https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host ""    
}

$localPath = $PWD.ToString()
$pathVal = Get-ItemProperty -path HKCU:\Environment\ -Name Path 

if (!$pathVal.Path.Contains($localPath))
{
    # assign permanent path
    Set-ItemProperty -path HKCU:\Environment\ -Name Path -Value "$((Get-ItemProperty -path HKCU:\Environment\ -Name Path).Path);$localPath"
    Write-Host "Your PATH Environment variable has been updated with:" -ForegroundColor Yellow
    Write-Host  $localPath -ForegroundColor Green

    # Assign current session path
    $ENV:PATH="$ENV:PATH;$localPath"
}
else {
    Write-Host "Path is already in your PATH environment variable." -ForegroundColor Yellow
}
