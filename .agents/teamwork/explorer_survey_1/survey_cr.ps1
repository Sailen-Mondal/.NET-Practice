$gacRoots = @(
    "C:\Windows\Microsoft.NET\assembly\GAC_MSIL",
    "C:\Windows\Microsoft.NET\assembly\GAC_32",
    "C:\Windows\Microsoft.NET\assembly\GAC_64",
    "C:\Windows\assembly\GAC_MSIL",
    "C:\Windows\assembly\GAC_32",
    "C:\Windows\assembly\GAC_64"
)

Write-Host "=== GAC SCAN FOR CRYSTAL DECISIONS ==="
foreach ($root in $gacRoots) {
    if (Test-Path $root) {
        $files = Get-ChildItem -Path $root -Recurse -Filter "CrystalDecisions*.dll" -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $vi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($f.FullName)
            [PSCustomObject]@{
                Root = (Split-Path $root -Leaf)
                Name = $f.Name
                FileVersion = $vi.FileVersion
                ProductVersion = $vi.ProductVersion
                FullPath = $f.FullName
            }
        }
    }
}

Write-Host "=== INSTALLED PROGRAMS (CRYSTAL REPORTS) ==="
$uninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
Get-ItemProperty $uninstallKeys -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*Crystal*" } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation, UninstallString

Write-Host "=== SAP BUSINESSOBJECTS REGISTRY ==="
Get-ChildItem "HKLM:\Software\SAP BusinessObjects" -Recurse -ErrorAction SilentlyContinue | Select-Object Name
Get-ChildItem "HKLM:\Software\Wow6432Node\SAP BusinessObjects" -Recurse -ErrorAction SilentlyContinue | Select-Object Name
