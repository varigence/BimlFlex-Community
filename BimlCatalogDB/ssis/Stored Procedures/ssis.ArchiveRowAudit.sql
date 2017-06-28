CREATE PROCEDURE [ssis].[ArchiveRowAudit]
AS
BEGIN
	DECLARE	 @RowAuditRetentionPeriod	INT
			,@RetentionDate				DATE
	
	SELECT	@RowAuditRetentionPeriod = -CONVERT(INT, [ConfigurationValue]) 
	FROM	[admin].[Configurations] 
	WHERE	[ConfigurationCode] = 'BimlFlex' 
		AND [ConfigurationKey] = 'RowAuditRetentionPeriod'
	
	SET		@RetentionDate = DATEADD(DD, @RowAuditRetentionPeriod, GETDATE())

	DECLARE @AuditRow TABLE ([AuditRowID] BIGINT PRIMARY KEY)

	INSERT INTO @AuditRow([AuditRowID])
	SELECT  DISTINCT ar.[AuditRowID]
	FROM	[ssis].[AuditRow] ar
	LEFT OUTER JOIN [ssis].[Execution] e
		ON	ar.[ExecutionID] = e.[ExecutionID]
	WHERE	(COALESCE(ar.[AuditDate], e.[StartTime], '1900-01-01')  < @RetentionDate OR ar.[RowCount] = 0)

	DELETE	ard
	FROM	[ssis].[AuditRowData] ard
	INNER JOIN @AuditRow art
		ON	ard.[AuditRowID] = art.[AuditRowID]

	
	DELETE	ar
	FROM	[ssis].[AuditRow] ar
	INNER JOIN @AuditRow art
		ON	ar.[AuditRowID] = art.[AuditRowID]

	DELETE	ard
	FROM	[ssis].[AuditRowData] ard
	LEFT OUTER JOIN [ssis].[AuditRow] ar
		ON	ard.[AuditRowID] = ar.[AuditRowID]
	WHERE	ar.[AuditRowID] IS NULL

	RETURN 0

END
