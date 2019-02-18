# Query to get a MS SQL instance name.

$obj = [PSCustomObject] @{
    data = @((get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | % {
        [PSCustomObject] @{
            '{#SQLINSTANCENAME}' = $_
            '{#SQLINSTANCE}' = if($_ -eq 'MSSQLSERVER') { "SQLServer" } else { "MSSQL`$$_" }
        }
    }) 
}
Write-Host $($obj | ConvertTo-Json)