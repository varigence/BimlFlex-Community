﻿DECLARE @tblInsert	TABLE(
	[ConfigurationCode]			VARCHAR (20)		NOT NULL,
	[ConfigurationKey]			VARCHAR (100)		NOT NULL,
    [ConfigurationValue]		VARCHAR (4000)		NOT NULL)

INSERT INTO @tblInsert([ConfigurationCode], [ConfigurationKey], [ConfigurationValue])
VALUES	 ('BimlFlex', 'PackageRetryLimit', '3')

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
