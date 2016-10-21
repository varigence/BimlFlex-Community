CREATE PROCEDURE [ssis].[ArchiveTaskExecution]
AS
BEGIN

	DECLARE	 @TaskExecutionRetentionPeriod	INT
			,@RetentionDate					DATE
	
	SELECT	@TaskExecutionRetentionPeriod = -CONVERT(INT, [ConfigurationValue]) 
	FROM	[admin].[Configurations] 
	WHERE	[ConfigurationCode] = 'BimlFlex' 
		AND [ConfigurationKey] = 'TaskExecutionRetentionPeriod'
	
	SET		@RetentionDate = DATEADD(DD, @TaskExecutionRetentionPeriod, GETDATE())

	DELETE	te
	FROM	[ssis].[TaskExecution] te
	WHERE	te.[TaskStartTime] < @RetentionDate
	
	RETURN 0

END
