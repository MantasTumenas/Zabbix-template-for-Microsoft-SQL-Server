# Query to get user database diff backup status.

Param(
    [string]$InstName,
    [string]$DBName,
	[string]$UDBDTIME1,
	[string]$UDBDTIME2,
	[string]$UDBDTIME3
)
 

if ($InstName -and $DBName)
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
				# Select the current instance name and user database differential backup status. 
				# Where database = the database that was passed on the cmdline.
				# Adjust "DATEADD(hh,-$UDBDTIME1,GETDATE())" parts according to your needs. Current setting is:
				#	Throw 11 when differential backup is not older then $UDBDTIME1 hours.
				#	Throw 12 when differential backup is older then $UDBDTIME1 hours.
				#	Throw 13 when differential backup is older then $UDBDTIME2 hours.
				#	Throw 14 when differential backup is older then $UDBDTIME3 hours.
				#	Throw 0 when backup status is not retrieved.
            $SqlCmd.CommandText = "SELECT ISNULL(MAX(state),0) AS state
									FROM (SELECT TOP 1 CASE
											WHEN backup_finish_date > DATEADD(hh,-$UDBDTIME1,GETDATE()) THEN 11			
											WHEN backup_finish_date <= DATEADD(hh,-$UDBDTIME1,GETDATE()) and backup_finish_date > DATEADD(hh,-$UDBDTIME2,GETDATE()) THEN 12
											WHEN backup_finish_date <= DATEADD(hh,-$UDBDTIME2,GETDATE()) and backup_finish_date > DATEADD(hh,-$UDBDTIME3,GETDATE()) THEN 13
											WHEN backup_finish_date <= DATEADD(hh,-$UDBDTIME3,GETDATE()) THEN 14
										ELSE 0
										END AS state
									FROM msdb.dbo.backupset
									WHERE database_name = '$DBName'
										AND type = 'I'
										AND backup_finish_date = (SELECT MAX(backup_finish_date)
													FROM msdb.dbo.backupset
													WHERE database_name = '$DBName'
													AND type = 'I'
													AND database_name NOT IN ('master', 'model', 'msdb', 'tempdb')))
									AS state"
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
    # We get a set of user database full backup statuses. Append them to the database name variable.
    if ($DataTable -and $DataTable.Rows.Count)
    {
        Write-Host $DataTable.Rows[0].state
    }
}