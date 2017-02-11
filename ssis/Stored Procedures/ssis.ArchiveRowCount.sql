CREATE PROCEDURE [ssis].[ArchiveRowCount]
AS
BEGIN
	DECLARE	 @RowCountRetentionPeriod	INT
			,@RetentionDate				DATE
	
	SELECT	@RowCountRetentionPeriod = -CONVERT(INT, [ConfigurationValue]) 
	FROM	[admin].[Configurations] 
	WHERE	[ConfigurationCode] = 'BimlFlex' 
		AND [ConfigurationKey] = 'RowCountRetentionPeriod'
	
	SET		@RetentionDate = DATEADD(DD, @RowCountRetentionPeriod, GETDATE())

	DECLARE @RowCount TABLE ([RowCountID] BIGINT PRIMARY KEY)

	INSERT INTO @RowCount([RowCountID])
	SELECT  DISTINCT ar.[RowCountID]
	FROM	[ssis].[RowCount] ar
	LEFT OUTER JOIN [ssis].[Execution] e
		ON	ar.[ExecutionID] = e.[ExecutionID]
	WHERE	(COALESCE(ar.[AuditDate], e.[StartTime], '1900-01-01')  < @RetentionDate OR ar.[RowCount] = 0)

	DELETE	ar
	FROM	[ssis].[RowCount] ar
	INNER JOIN @RowCount art
		ON	ar.[RowCountID] = art.[RowCountID]

	RETURN 0

END
