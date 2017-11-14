CREATE PROCEDURE [ssis].[ArchiveConfigVariable]
AS
BEGIN
	DECLARE	 @RetentionPeriod		INT
			,@RetentionDate			DATE
	
	SELECT	@RetentionPeriod = -CONVERT(INT, [ConfigurationValue]) 
	FROM	[admin].[Configurations] 
	WHERE	[ConfigurationCode] = 'BimlFlex' 
		AND [ConfigurationKey] = 'ConfigVariablePeriod'
	
	SET		@RetentionDate = DATEADD(DD, @RetentionPeriod, GETDATE())

	DELETE	ar
	FROM	[ssis].[AuditConfigVariable] ar
	WHERE	[RowLastModified]  < @RetentionDate

	RETURN 0

END
