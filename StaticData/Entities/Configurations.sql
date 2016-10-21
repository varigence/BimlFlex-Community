DECLARE @tblInsert	TABLE(
	[ConfigurationCode]			VARCHAR (20)		NOT NULL,
	[ConfigurationKey]			VARCHAR (100)		NOT NULL,
    [ConfigurationValue]		VARCHAR (4000)		NOT NULL)

INSERT INTO @tblInsert([ConfigurationCode], [ConfigurationKey], [ConfigurationValue])
VALUES	 ('BimlFlex', 'PackageRetryLimit', '3')
		,('BimlFlex', 'SSISDB', 'SSISDB')
		,('BimlFlex', 'RowAuditRetentionPeriod', '30')
		,('BimlFlex', 'TaskExecutionRetentionPeriod', '30')
		,('BimlFlex', 'LogTaskExecution', 'Y')

MERGE [admin].[Configurations] AS TARGET
USING @tblInsert AS src
	ON	TARGET.[ConfigurationCode] = src.[ConfigurationCode]
	AND	TARGET.[ConfigurationKey] = src.[ConfigurationKey]
WHEN MATCHED THEN 
		UPDATE 
		SET		 [ConfigurationValue] = src.[ConfigurationValue]
WHEN NOT MATCHED THEN
	INSERT	([ConfigurationCode]
			,[ConfigurationKey]
			,[ConfigurationValue])
	VALUES	([ConfigurationCode]
			,[ConfigurationKey]
			,[ConfigurationValue]);
GO
