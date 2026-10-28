$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$xsdPath = Join-Path $projDir "App_Code\CandidateDataSet.xsd"
$ds = New-Object System.Data.DataSet
$ds.ReadXmlSchema($xsdPath)

Write-Output "CandidateDataSet Tables Count: $($ds.Tables.Count)"
foreach ($tbl in $ds.Tables) {
    Write-Output "Table: $($tbl.TableName)"
    foreach ($col in $tbl.Columns) {
        Write-Output "  $($col.ColumnName) : $($col.DataType.FullName)"
    }
}
