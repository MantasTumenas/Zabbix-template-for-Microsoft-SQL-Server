# Query to get instance name.

$obj = [PSCustomObject] @{
    data = @((get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | % {
        [PSCustomObject] @{
            '{#SQLINSTANCENAME}' = $_
            '{#SQLINSTANCE}' = if($_ -eq 'MSSQLSERVER') { "SQLServer" } else { "MSSQL`$$_" }
			'{#SQLINSTANCESERVICE}' = if($_ -eq 'MSSQLSERVER') { "MSSQLSERVER" } else { "MSSQL`$$_" }
			'{#SQLINSTANCESQLCMD}' = if($_ -eq 'MSSQLSERVER') { "default" } else { "$_" }
        }
    }) 
}
Write-Host $($obj | ConvertTo-Json)