CREATE PROC [ssis].[LogTaskExecution]
	@SourceGUID				[nvarchar](40),
	@PackageID				[int],
	@ExecutionID			[bigint],
	@ServerExecutionID		[bigint]
AS
SET NOCOUNT ON

DECLARE	@Sql	NVARCHAR(MAX)

CREATE TABLE #TASK_EXECUTION(
	[TaskName]				NVARCHAR(1000),
	[TaskExecutionGUID]		NVARCHAR(36),
	[TaskExecutionOrder]	BIGINT,
	[TaskExecutionDuration]	BIGINT
)

CREATE TABLE #TASK_ERROR(
	[TaskExecutionGUID]		NVARCHAR(36),
	[TaskErrorOrder]		BIGINT,
	[TaskErrorMessage]		NVARCHAR(MAX)
)

IF (@ServerExecutionID <> -1)
BEGIN
	DECLARE	@ssisdb			NVARCHAR(128)
	SET	@ssisdb = ISNULL((SELECT TOP 1 CONVERT(NVARCHAR(128), [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'SSISDB'), 'SSISDB')
	
	SET		@Sql = 'SELECT	 LEFT([TaskName], 1000) AS [TaskName]
			,LEFT(REPLACE(REPLACE([TaskExecutionGUID], ''{'', ''''), ''}'', ''''), 36) AS [TaskExecutionGUID]
			,RANK() OVER (ORDER BY [TaskExecutionGUID], [TaskStartTime] ASC) AS [TaskExecutionOrder]
			,[TaskExecutionDuration]
	FROM 
	(
		SELECT	 scet.[executable_name] AS [TaskName]
				,scet.[executable_guid] AS [TaskExecutionGUID]
				,MAX(sces.[start_time]) AS [TaskStartTime]
				,MAX(sces.[execution_duration]) AS [TaskExecutionDuration]
		FROM	[' + @ssisdb + '].[catalog].[executables] sce 
		INNER JOIN [' + @ssisdb + '].[catalog].[executables] scet
			ON	sce.[execution_id] = scet.[execution_id]
			AND	sce.[package_name] = scet.[package_name]
		INNER JOIN [' + @ssisdb + '].[catalog].[executable_statistics] sces
			ON	scet.[executable_id] = sces.[executable_id]
			AND	scet.[execution_id] = sces.[execution_id]
		WHERE	''{' + @SourceGUID  + '}'' = sce.[executable_guid]  
			AND		sce.[execution_id] = ' + CONVERT(VARCHAR(24), @ServerExecutionID) + '
			AND		scet.[package_path] <> ''\Package''
			AND		LEFT(scet.[executable_name], 5) NOT IN (''FRL -'', ''SEQC '', ''SECQ '')
		GROUP BY scet.[executable_name]
				,scet.[executable_guid]
	) AS src'

	INSERT INTO #TASK_EXECUTION([TaskName], [TaskExecutionGUID], [TaskExecutionOrder], [TaskExecutionDuration])
	EXEC (@Sql)

	SET		@Sql = 'SELECT	 LEFT(REPLACE(REPLACE(scem.[message_source_id], ''{'', ''''), ''}'', ''''), 36) AS [TaskExecutionGUID] 
			,RANK() OVER (PARTITION BY scem.[message_source_id] ORDER BY scem.[message_time]) AS [TaskErrorOrder]
			,scem.[message] AS [TaskErrorMessage]
	FROM	[' + @ssisdb + '].[catalog].[executables] sce 
	INNER JOIN [' + @ssisdb + '].[catalog].[executables] scet
		ON	sce.[execution_id] = scet.[execution_id]
		AND	sce.[package_name] = scet.[package_name]
	INNER JOIN [' + @ssisdb + '].[catalog].[event_messages] scem
		ON	scet.[execution_id] = scem.[operation_id]
		AND	scem.[message_source_id] = scet.[executable_guid]
	WHERE	''{' + @SourceGUID  + '}'' = sce.[executable_guid]  
		AND		sce.[execution_id] = ' + CONVERT(VARCHAR(24), @ServerExecutionID) + '
		AND		scet.[package_path] <> ''\Package''
		AND		LEFT(scet.[executable_name], 5) NOT IN (''FRL -'', ''SEQC '', ''SECQ '')
		AND		scem.[event_name] = ''OnError'''


	INSERT INTO #TASK_ERROR([TaskExecutionGUID], [TaskErrorOrder], [TaskErrorMessage])
	EXEC (@Sql)

	INSERT INTO [ssis].[Task]
			([PackageID]
			,[TaskName]
			,[TaskOrder])
	SELECT	DISTINCT
			 @PackageID
			,te.[TaskName]
			,te.[TaskExecutionOrder]
	FROM	#TASK_EXECUTION te
	LEFT OUTER JOIN [ssis].[Task] t
		ON	te.[TaskName] COLLATE DATABASE_DEFAULT = t.[TaskName] COLLATE DATABASE_DEFAULT
		AND	t.[PackageID] = @PackageID

	INSERT INTO [ssis].[TaskExecution]
			([ExecutionID]
			,[TaskExecutionGUID]
			,[TaskID]
			,[TaskExecutionOrder]
			,[TaskExecutionDuration])
	SELECT	 @ExecutionID
			,[TaskExecutionGUID]
			,t.[TaskID]
			,te.[TaskExecutionOrder]
			,te.[TaskExecutionDuration]
	FROM	#TASK_EXECUTION te
	INNER JOIN [ssis].[Task] t
		ON	te.[TaskName] COLLATE DATABASE_DEFAULT = t.[TaskName] COLLATE DATABASE_DEFAULT
		AND	t.[PackageID] = @PackageID

	INSERT INTO [ssis].[TaskExecutionError]
			([ExecutionID]
			,[TaskExecutionGUID]
			,[TaskErrorMessage])
	SELECT	 @ExecutionID
			,[TaskExecutionGUID]
			,[TaskErrorMessage]
	FROM	#TASK_ERROR
END

GO