https://learn.microsoft.com/en-us/sql/relational-databases/databases/database-instant-file-initialization?view=sql-server-ver16


secpol.msc


To grant an account the Perform volume maintenance tasks permission:
	1. On the computer where the data file will be created, open the Local Security Policy application (secpol.msc).
	2. In the left pane, expand Local Policies, and then select User Rights Assignment (Atribuicao de diretos do usuario).
	3. In the right pane, double-click Perform volume maintenance tasks (Executar tarefas de manutenção de Volume)
	4. Select Add User or Group and add the account that runs the SQL Server service.
	5. Select Apply, and then close all Local Security Policy dialog boxes.
	6. Restart the SQL Server service.
	7. Check the SQL Server error log at startup.Applies to: SQL Server (Starting with SQL Server 2012 (11.x) SP4, SQL Server 2014 (12.x) SP2, and SQL Server 2016 (13.x) and later).
	8. If the SQL Server service startup account is granted SE_MANAGE_VOLUME_NAME, an informational message that resembles the following example is logged:Database Instant File Initialization: enabled. For security and performance considerations see the topic 'Database Instant File Initialization' in SQL Server Books Online. This is an informational message only. No user action is required.
	9. If the SQL Server service startup account has not been granted SE_MANAGE_VOLUME_NAME, an informational message that resembles the following example is logged:Database Instant File Initialization: disabled. For security and performance considerations see the topic 'Database Instant File Initialization' in SQL Server Books Online. This is an informational message only. No user action is required. NoteIn SQL Server, use the value of instant_file_initialization_enabled in the sys.dm_server_services dynamic management view to identify if instant file initialization is enabled for your instance.
