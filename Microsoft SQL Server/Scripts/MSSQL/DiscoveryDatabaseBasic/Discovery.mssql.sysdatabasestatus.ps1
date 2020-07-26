# Query to get database status.

Param(
    [string]$instName,
    [string]$dbName
)
 

if ($instName -and $dbName)
{
    $fullInstanceName = if ($instName -eq 'MSSQLSERVER') { $env:computername } else { "$env:computername\$instName" }
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
            # Select the current instance name and database status 
            # where database = the database that was passed on the cmdline
            $SqlCmd.CommandText = "IF @@VERSION > 'Microsoft SQL Server 201'+'%'
									SELECT CASE
										WHEN db.state = 1 AND dbm.mirroring_state_desc = 'SYNCHRONIZED' THEN 21
										WHEN db.state = 1 AND dbm.mirroring_state_desc = 'SYNCHRONIZING' THEN 22
										WHEN db.state = 0 AND dbm.mirroring_state_desc = 'SYNCHRONIZED' THEN 23
										WHEN db.state = 1 AND dbm.mirroring_state_desc IN ('DISCONNECTED','PENDING_FAILOVER','SUSPENDED','UNSYNCHRONIZED') THEN 25
										WHEN db.state = 0 AND dbm.mirroring_state_desc IN ('DISCONNECTED','PENDING_FAILOVER','SUSPENDED','UNSYNCHRONIZED') THEN 26
										WHEN db.state = 0 AND hadr.synchronization_health = 2 THEN 31 
										WHEN db.state = 0 AND hadr.synchronization_health <> 2 THEN 35 
										WHEN db.state = 0 AND lsms.secondary_database = '$dbName' THEN 40
										WHEN db.state = 1 AND lsms.secondary_database = '$dbName' THEN 41
										WHEN db.state = 2 AND lsms.secondary_database = '$dbName' THEN 42
										ELSE db.state
									END AS state
									FROM sys.databases AS db LEFT JOIN master.sys.database_mirroring AS dbm ON db.database_id = dbm.database_id 
										LEFT JOIN (SELECT * FROM master.sys.dm_hadr_database_replica_states WHERE is_local = 1) AS hadr ON db.database_id = hadr.database_id 
										LEFT JOIN msdb.dbo.log_shipping_monitor_secondary AS lsms ON db.name = lsms.secondary_database 
									WHERE db.name = '$dbName'
								ELSE
									SELECT CASE 
										WHEN db.state = 1 AND dbm.mirroring_state_desc = 'SYNCHRONIZED' THEN 21
										WHEN db.state = 1 AND dbm.mirroring_state_desc = 'SYNCHRONIZING' THEN 22
										WHEN db.state = 0 AND dbm.mirroring_state_desc = 'SYNCHRONIZED' THEN 23
										WHEN db.state = 1 AND dbm.mirroring_state_desc IN ('DISCONNECTED','PENDING_FAILOVER','SUSPENDED','UNSYNCHRONIZED') THEN 25
										WHEN db.state = 0 AND dbm.mirroring_state_desc IN ('DISCONNECTED','PENDING_FAILOVER','SUSPENDED','UNSYNCHRONIZED') THEN 26  
										WHEN db.state = 0 AND lsms.secondary_database = '$dbName' THEN 40
										WHEN db.state = 1 AND lsms.secondary_database = '$dbName' THEN 41
										WHEN db.state = 2 AND lsms.secondary_database = '$dbName' THEN 42
										ELSE db.state
									END AS state 
									FROM sys.databases AS db LEFT JOIN master.sys.database_mirroring AS dbm ON db.database_id = dbm.database_id 
										LEFT JOIN msdb.dbo.log_shipping_monitor_secondary AS lsms ON db.name = lsms.secondary_database
									WHERE db.name = '$dbName'"
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
        Write-Host "256"
        $DataTable = $null
    }
    # We get a set of database statuses. Append them to the basename variable.
    if ($DataTable -and $DataTable.Rows.Count)
    {
        Write-Host $DataTable.Rows[0].state
    }
}