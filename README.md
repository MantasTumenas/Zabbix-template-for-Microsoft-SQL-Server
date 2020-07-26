# Zabbix template for Microsoft SQL Server
Features: MS SQL performance counters, MS SQL instance Low Level Discovery, MS SQL database Low Level Discovery, MS SQL database backup Low Level Discovery, MS SQL agent job Low Level Discovery, MS SQL database mirroring monitoring, MS SQL Always On monitoring, MS SQL Log Shipping monitoring.

Supported versions:
Tested on Microsoft SQL Server 2012, 2014 2016 and 2019. It may work with earlier versions, but some items (with missing performance counters) may be unsupported. For the extensive overview on the performance counters difference between MS SQL 2008 and MS SQL 2012 you can read here (https://blog.dbi-services.com/sql-server-2012-new-perfmon-counters/).
Tested on Zabbix 3.4.0. and 4.0.0. It may work with earlier versions, but some items (for example service.info[service,]) may be unsupported. The template was started on Zabbix 2.4.0 but after each new Zabbix version, objects were modified or new things were added.
