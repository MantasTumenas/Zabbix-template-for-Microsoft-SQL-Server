# Query to get agent name.

$obj = [PSCustomObject] @{
    data = @((get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | % {
        [PSCustomObject] @{
            '{#SQLAGENTNAME}' = $_
			'{#SQLINSTANCENAME}' = $_
            '{#SQLAGENT}' = if($_ -eq 'MSSQLSERVER') { "SQLAgent" } else { "SQLAgent`$$_" }
            '{#SQLAGENTSERVICE}' = if($_ -eq 'MSSQLSERVER') { "SQLSERVERAGENT" } else { "SQLAgent`$$_" }
        }
    }) 
}
Write-Host $($obj | ConvertTo-Json)