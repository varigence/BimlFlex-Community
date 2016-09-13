CREATE PROC [ssis].[LogTaskExecution]
	@SourceGUID				[nvarchar](40),
	@PackageID				[int],
	@ExecutionID			[bigint],
	@ServerExecutionID		[bigint]
AS
SET NOCOUNT ON

IF (@ServerExecutionID <> -1)
BEGIN
	SELECT	 LEFT([TaskName], 1000) COLLATE DATABASE_DEFAULT AS [TaskName]
			,LEFT(REPLACE(REPLACE([TaskExecutionGUID], '{', ''), '}', ''), 36) COLLATE DATABASE_DEFAULT AS [TaskExecutionGUID]
			,RANK() OVER (ORDER BY [TaskExecutionGUID], [TaskStartTime] ASC) AS [TaskExecutionOrder]
			,[TaskExecutionDuration]
	INTO	#TASK_EXECUTION
	FROM 
	(
		SELECT	 scet.[executable_name] AS [TaskName]
				,scet.[executable_guid] AS [TaskExecutionGUID]
				,MAX(sces.[start_time]) AS [TaskStartTime]
				,MAX(sces.[execution_duration]) AS [TaskExecutionDuration]
		FROM	[catalog].[executables] sce 
		INNER JOIN [catalog].[executables] scet
			ON	sce.[execution_id] = scet.[execution_id]
			AND	sce.[package_name] = scet.[package_name]
		INNER JOIN [catalog].[executable_statistics] sces
			ON	scet.[executable_id] = sces.[executable_id]
			AND	scet.[execution_id] = sces.[execution_id]
		WHERE	'{' + @SourceGUID COLLATE DATABASE_DEFAULT + '}' = sce.[executable_guid]  COLLATE DATABASE_DEFAULT 
		AND		sce.[execution_id] = @ServerExecutionID
		AND		scet.[package_path] <> '\Package'
		AND		LEFT(scet.[executable_name], 5) NOT IN ('FRL -', 'SEQC ', 'SECQ ')
		GROUP BY scet.[executable_name]
				,scet.[executable_guid]
	) AS src

	SELECT	 LEFT(REPLACE(REPLACE(scem.[message_source_id], '{', ''), '}', ''), 36) COLLATE DATABASE_DEFAULT AS [TaskExecutionGUID] 
			,RANK() OVER (PARTITION BY scem.[message_source_id] ORDER BY scem.[message_time]) AS [TaskErrorOrder]
			,scem.[message] AS [TaskErrorMessage]
	INTO	#TASK_ERROR
	FROM	[catalog].[event_messages] scem
	WHERE	scem.[operation_id] = @ServerExecutionID
	AND		scem.[event_name] = 'OnError'
	AND		scem.[message_source_id] COLLATE DATABASE_DEFAULT IN (SELECT DISTINCT [TaskExecutionGUID] FROM #TASK_EXECUTION) 

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
		ON	te.[TaskName] = t.[TaskName] 
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
		ON	te.[TaskName] = t.[TaskName] 
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
