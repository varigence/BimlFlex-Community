/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TRIGGER [ssis].[trg_ConfigVariableAudit]
	ON [ssis].[ConfigVariable]
	FOR DELETE, INSERT, UPDATE
AS
SET NOCOUNT ON
DECLARE  @tableName		VARCHAR(128) = 'ConfigVariable'
		,@schema		VARCHAR(128) = 'ssis'
		,@bit			INT
		,@field			INT
		,@maxfield		INT
		,@char			INT
		,@fieldname		VARCHAR(128)
		,@sql			VARCHAR(2000) 
		,@auditType		CHAR(1)	= 'I'

-- AuditauditType
IF NOT EXISTS (SELECT 1 FROM inserted) 
	SET @auditType = 'D'
ELSE IF EXISTS (SELECT 1 FROM deleted) 
	SET @auditType = 'U'
       
-- get list of columns
SELECT * INTO #ins FROM inserted
SELECT * INTO #del FROM deleted

SELECT	@field = 0, 
		@maxfield = MAX(ORDINAL_POSITION)
FROM	INFORMATION_SCHEMA.COLUMNS 
WHERE	TABLE_NAME = @tableName
AND		TABLE_SCHEMA = @schema

WHILE	@field < @maxfield
BEGIN
	SELECT	@field = MIN(ORDINAL_POSITION) 
	FROM	INFORMATION_SCHEMA.COLUMNS 
	WHERE	TABLE_NAME = @tableName 
	AND		TABLE_SCHEMA = @schema
	AND		ORDINAL_POSITION > @field

	SELECT @bit = (@field - 1 )% 8 + 1
	SELECT @bit = POWER(2,@bit - 1)
	SELECT @char = ((@field - 1) / 8) + 1
	IF SUBSTRING(COLUMNS_UPDATED(),@char, 1) & @bit > 0 OR @auditType IN ('I','D')
	BEGIN
		SELECT	@fieldname = COLUMN_NAME 
		FROM	INFORMATION_SCHEMA.COLUMNS 
		WHERE	TABLE_NAME = @tableName 
		AND		TABLE_SCHEMA = @schema
		AND		ORDINAL_POSITION = @field

		SET @sql = 'INSERT [ssis].[AuditLog] 
		([AuditType]
		,[TableName]
		,[KeyId]
		,[ColumnName]
		,[OldValue]
		,[NewValue])
SELECT	''' + @auditType + '''
		,''' + @tableName + '''
		,ISNULL(i.[ConfigVariableID], d.[ConfigVariableID]) AS [KeyId]
		,''' + @fieldname + '''
		,CONVERT(VARCHAR(4000), d.[' + @fieldname + '])
		,CONVERT(VARCHAR(4000), i.[' + @fieldname + '])
FROM	#ins i 
FULL OUTER JOIN #del d
	ON	i.[ConfigVariableID] = d.[ConfigVariableID]
WHERE	i.[' + @fieldname + '] <> d.[' + @fieldname + ']
	OR	(i.[' + @fieldname + '] IS NULL AND  d.[' + @fieldname + '] IS NOT NULL)
	OR	(i.[' + @fieldname + '] IS NOT NULL AND  d.[' + @fieldname + '] IS NULL)' 
		EXEC (@sql)
	END
END

GO
