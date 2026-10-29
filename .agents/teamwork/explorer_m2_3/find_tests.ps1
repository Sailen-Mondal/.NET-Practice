$files = Get-ChildItem 'D:\.NET\ViewModelDemo\Tests\E2E\Tier*.ps1'
$results = @()
foreach ($f in $files) {
    $content = Get-Content $f.FullName -Encoding UTF8
    foreach ($line in $content) {
        if ($line -match 'Register-TestCase\s+-Id\s+"([^"]+)"\s+-Tier\s+"([^"]+)"\s+-Feature\s+"([^"]+)"\s+-Title\s+"([^"]+)"') {
            $id = $Matches[1]
            $tier = $Matches[2]
            $feature = $Matches[3]
            $title = $Matches[4]
            if ($feature -match 'F01|F02|F03|F04|F11|F12' -or $id -match 'F01|F02|F03|F04|F11|F12') {
                $results += [PSCustomObject]@{
                    File = $f.Name
                    Id = $id
                    Tier = $tier
                    Feature = $feature
                    Title = $title
                }
            }
        }
    }
}
$results | Sort-Object File, Id | Format-Table -Property File, Id, Feature, Title -AutoSize | Out-String -Width 220
