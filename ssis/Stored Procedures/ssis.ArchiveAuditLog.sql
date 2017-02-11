CREATE PROCEDURE [ssis].[ArchiveAuditLog]
AS
BEGIN
	DECLARE	 @AuditLogRetentionPeriod	INT
			,@RetentionDate				DATE
	
	SELECT	@AuditLogRetentionPeriod = -CONVERT(INT, [ConfigurationValue]) 
	FROM	[admin].[Configurations] 
	WHERE	[ConfigurationCode] = 'BimlFlex' 
		AND [ConfigurationKey] = 'AuditLogRetentionPeriod'
	
	SET		@RetentionDate = DATEADD(DD, @AuditLogRetentionPeriod, GETDATE())

	DELETE	ar
	FROM	[ssis].[AuditLog] ar
	WHERE	[ModifiedDate] < @RetentionDate

	RETURN 0
END
