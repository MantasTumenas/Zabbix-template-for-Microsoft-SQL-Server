# Query sum of database maintenance jobs which are enabledand are in Database Maintenance category.

Param(
    [string]$InstName
)
 

if ($InstName)
{
    $fullInstanceName = if ($InstName -eq 'MSSQLSERVER') { $env:computername } else { "$env:computername\$InstName" }
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
		#"Error connecting to $fullInstance!"
        Write-Host "255"
		
        $DataSet = $null
        $connection = $null
    }
    try
    {
        # Only run our queries if connection isn't null
        if ($connection -ne $null)
        {
            # Create a MSSQL request
            $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
            	# Select the current instance name and query sum of database maintenance jobs which jobs are enabled. 
            $SqlCmd.CommandText = "SELECT COUNT(*) AS count
									FROM msdb.dbo.sysjobs AS J
									INNER JOIN msdb.dbo.syscategories AS C ON J.category_id = C.category_id
									WHERE C.name = 'Database Maintenance'
										AND J.enabled = 1"
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
        # If our query failed, set our dataset to null
		# Write-Host "Error executing query on $fullInstance!"
        Write-Host "256"
		
        $DataTable = $null
    }
    # We get a set of system database full backup statuses. Append them to the database name variable.
    if ($DataTable -and $DataTable.Rows.Count)
    {
        Write-Host $DataTable.Rows[0].count
    }
}