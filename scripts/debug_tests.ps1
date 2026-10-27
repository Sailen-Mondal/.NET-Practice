$xsdPath = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\App_Code\CandidateDataSet.xsd"
$ds = New-Object System.Data.DataSet
$ds.ReadXmlSchema($xsdPath)
$col = $ds.Tables["Candidate"].Columns["PhotoData"]
Write-Host "Column PhotoData DataType:" $col.DataType.FullName

$largeBlob = New-Object byte[] (5 * 1024 * 1024)
Write-Host "largeBlob GetType():" $largeBlob.GetType().FullName
Write-Host "largeBlob is byte[]:" ($largeBlob -is [byte[]])

$row = $ds.Tables["Candidate"].NewRow()
try {
    # In PowerShell, assigning directly to DataRow indexer can trigger PowerShell unrolling/casting
    $row.Item("PhotoData") = [byte[]]$largeBlob
    Write-Host "Assigned via Item successfully!"
} catch {
    Write-Host "Error assigning via Item:" $_.Exception.ToString()
}

try {
    # What about SetField?
    $row["PhotoData"] = ,$largeBlob
    Write-Host "Assigned via comma unary operator successfully!"
} catch {
    Write-Host "Error assigning via comma operator:" $_.Exception.ToString()
}
