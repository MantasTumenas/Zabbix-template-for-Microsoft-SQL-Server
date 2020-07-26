# Query to get a MS SQL agent job status.

Param(
    [string]$instName,
    [string]$jobName
)
 

if ($instName -and $jobName)
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
            # Create a MS SQL request
            $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
            # Select the current instance name and job status 
            # where job = the job that was passed on the cmdline
            $SqlCmd.CommandText = "IF EXISTS
										(SELECT TOP 1 JH.run_status 
										FROM msdb.dbo.sysjobhistory AS JH LEFT JOIN msdb.dbo.sysjobs AS J ON JH.job_id = J.job_id 
										WHERE J.name = '$jobName' AND JH.step_name = '(Job outcome)')
										SELECT TOP 1 JH.run_status 
										FROM msdb.dbo.sysjobhistory AS JH LEFT JOIN msdb.dbo.sysjobs AS J ON JH.job_id = J.job_id 
										WHERE J.name = '$jobName' AND JH.step_name = '(Job outcome)' 
										ORDER BY JH.run_date DESC, JH.run_time DESC
									ELSE
										SELECT 11 AS 'run_status'"
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
    # We get a set of job status. Append them to the job name variable.
    if ($DataTable -and $DataTable.Rows.Count)
    {
        Write-Host $DataTable.Rows[0].run_status
    }
}