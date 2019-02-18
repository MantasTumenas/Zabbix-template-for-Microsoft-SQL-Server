# Desenvolvido por Diego Cavalcante - 06/12/2017
# Monitoramento Windows SQLServer
# Versco: 1.1.0
# Criaeco = Versco 1.0.0 29/08/2017 (Script Bisico).
# Update  = Versco 1.1.0 02/01/2018 (Obrigado @bernardolankheet, JOBSTATUS Retornava N = 5 Nunca Executado).
# Update  = by Oleg D. and Mantas T. Translated to EN, added SQL Insance name.

# Parameters. Change Line 14 $SQLInstanceName="InstanceName" to correct instance name

Param(

[Parameter(Mandatory = $true, Position = 0)]  [string]$select,
  [Parameter(Mandatory = $false, Position = 1)][string]$2,
  [Parameter(Mandatory = $false, Position = 2)]$SQLInstanceName="EnterInstanceName"

)

#Login SQLInstanceName
#$uid = "Login"
#$pwd = "Password"

# Construct JSON from queried databases names.
if ( $select -eq 'JSONDBNAME' ) 
{
$database = sqlcmd -S $SQLInstanceName -d master -h -1 -W -Q "set nocount on;SELECT name FROM master..sysdatabases"
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($db in $database)
{
    if ($idx -lt $database.Count)
    {
        $line= "{ `"{#DBNAME}`" : `"" + $db + "`" },"
        write-host $line
    }
    elseif ($idx -ge $database.Count)
    {
    $line= "{ `"{#DBNAME}`" : `"" + $db + "`" }"
    write-host $line
    }
    $idx++;
}
write-host
write-host " ]"
write-host "}"
} 

# Query database status.
if ( $select -eq 'DBSTATUS' )
{
sqlcmd -S $SQLInstanceName -d master -h -1 -W -Q "set nocount on;SELECT coalesce(max(state),7) from sys.databases where name = '$2'"
}

# Query connections to the database.
if ( $select -eq 'DBCONN' )
{
sqlcmd -S $SQLInstanceName -d master -h -1 -W -Q "set nocount on;DECLARE @AllConnections TABLE(
    SPID INT,
    Status VARCHAR(MAX),
    LOGIN VARCHAR(MAX),
    HostName VARCHAR(MAX),
    BlkBy VARCHAR(MAX),
    DBName VARCHAR(MAX),
    Command VARCHAR(MAX),
    CPUTime INT,
    DiskIO INT,
    LastBatch VARCHAR(MAX),
    ProgramName VARCHAR(MAX),
    SPID_1 INT,
    REQUESTID INT
)
INSERT INTO @AllConnections EXEC sp_who2
SELECT count(*) FROM @AllConnections WHERE DBName = '$2'"
}

# Construct JSON from queried jobs names.
if ( $select -eq 'JSONJOBNAME' )
{
$jobname = sqlcmd -S $SQLInstanceName -d msdb -h -1 -W -Q "set nocount on;SELECT [name] FROM msdb.dbo.sysjobs"
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($job in $jobname)
{
    if ($idx -lt $jobname.Count)
    {
        $line= "{ `"{#JOBNAME}`" : `"" + $job + "`" },"
        write-host $line
    }
    elseif ($idx -ge $jobname.Count)
    {
    $line= "{ `"{#JOBNAME}`" : `"" + $job + "`" }"
    write-host $line
    }
    $idx++;
}
write-host
write-host " ]"
write-host "}"
}

# Query jobstatus.
if ( $select -eq 'JOBSTATUS' )
{
sqlcmd -S $SQLInstanceName -d msdb -h -1 -W -Q "set nocount on;WITH last_hist_rec AS
(
SELECT ROW_NUMBER() OVER
(PARTITION BY job_id ORDER BY run_date DESC, run_time DESC) AS [RowNum]
, job_id
, run_date AS [last_run_date]
, run_time AS [last_run_time]
, CASE run_status
WHEN 0 THEN '0'
WHEN 1 THEN '1'
WHEN 2 THEN '2'
WHEN 3 THEN '3'
WHEN 4 THEN '4'
END AS [status]
FROM msdb.dbo.sysjobhistory
)
SELECT jobs.name AS [job_name]
, hist.status
FROM msdb.dbo.sysjobs jobs
LEFT JOIN last_hist_rec hist ON hist.job_id = jobs.job_id
AND hist.RowNum = 1
WHERE jobs.name = '$2'" | % {$_.substring($_.length-1) -replace ''} | ForEach-Object {$_ -Replace "N", "5"}
}