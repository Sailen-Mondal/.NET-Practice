$gacRoots = @(
    "C:\Windows\Microsoft.NET\assembly\GAC_MSIL",
    "C:\Windows\Microsoft.NET\assembly\GAC_32",
    "C:\Windows\Microsoft.NET\assembly\GAC_64"
)

$results = @()
foreach ($root in $gacRoots) {
    if (Test-Path $root) {
        $files = Get-ChildItem -Path $root -Recurse -Filter "CrystalDecisions*.dll" -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            $vi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($f.FullName)
            $an = $null
            try {
                $an = [System.Reflection.AssemblyName]::GetAssemblyName($f.FullName)
            } catch {}
            $results += [PSCustomObject]@{
                GAC = (Split-Path $root -Leaf)
                Name = $f.Name
                AssemblyVersion = if ($an) { $an.Version.ToString() } else { "N/A" }
                PublicKeyToken = if ($an) { [System.BitConverter]::ToString($an.GetPublicKeyToken()).Replace("-","").ToLower() } else { "N/A" }
                ProcessorArchitecture = if ($an) { $an.ProcessorArchitecture.ToString() } else { "N/A" }
                FileVersion = $vi.FileVersion
                Path = $f.FullName
            }
        }
    }
}

$results | Out-File -FilePath "d:\.NET\.agents\teamwork\explorer_survey_1\cr_gac_report.txt" -Width 300

$uninstall = Get-ItemProperty @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
) -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*Crystal*" } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation, InstallDate

$uninstall | Out-File -FilePath "d:\.NET\.agents\teamwork\explorer_survey_1\cr_installed_report.txt" -Width 300

Write-Host "Done writing reports."
