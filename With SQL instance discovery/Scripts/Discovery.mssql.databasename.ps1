# Query to get a MS SQL database name.

function get-instance-dbnames([string]$instanceName)
{
    $fullInstanceName = if ($instanceName -eq 'MSSQLSERVER') { $env:computername } else { "$env:computername\$instanceName" }
    $connectionString = "Server = $fullInstanceName; Integrated Security = True;"

    # Create a new connection object with that connection string
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    # Try to open our connection, if it fails we won't try to run any queries
    try
    {
        $connection.Open()
    }
    catch
    {
        #Write-Host "Error connecting to $fullInstance!"
        $DataSet = $null
        $connection = $null
    }
    try
    {
        # Only run our queries if connection isn't null
        if ($connection -ne $null)
        {
            # Create a MS SQL request
            $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
            # Select all the database names within this instance  
            $SqlCmd.CommandText = "SELECT name FROM master..sysdatabases"
            $SqlCmd.Connection = $Connection
            $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
            $SqlAdapter.SelectCommand = $SqlCmd
            $DataTable = New-Object System.Data.DataTable
            $SqlAdapter.Fill($DataTable) > $null
            $Connection.Close()
        }
    }
    catch
    {
        $DataTable = $null
    }

    if ($DataTable)
    {
		$DataTable.Rows | %{
			[PSCustomObject] @{
				'{#SQLINSTANCENAME}' = $instanceName
				'{#DBNAME}' = $_.name
				'{#SQLINSTANCE}' = if ($instanceName -eq 'MSSQLSERVER') { "SQLServer" } else { "MSSQL`$$instanceName" }
			}
		}
        
    }
}


$obj = [PSCustomObject] @{
    data = @((get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances | % {
            get-instance-dbnames($_)
        }) 
}

Write-Host $($obj | ConvertTo-Json)