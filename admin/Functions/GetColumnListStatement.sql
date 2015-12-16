/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE FUNCTION [admin].[GetColumnListStatement] 
(
	 @Catalog				NVARCHAR(128)
	,@QualifiedToTable		NVARCHAR(500)
	,@QualifiedTable		NVARCHAR(500)

) 
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN 
    (   
		SELECT	'USE [' + @Catalog + ']
SELECT	s.[name] AS [ColumnName]
		,sst.[name] AS [FromDataType]
		,tst.[name] AS [ToDataType]
		,CAST(t.[max_length] AS VARCHAR)
		,CAST(t.[precision] AS VARCHAR)
		,CAST(t.[scale] AS VARCHAR)
FROM [sys].[columns] s
INNER JOIN [sys].[columns] t
	ON	s.[name] = t.[name]
INNER JOIN [sys].[systypes] tst
	ON	t.[system_type_id] = tst.[xtype]
	AND	t.[user_type_id] = tst.[xusertype]
INNER JOIN [sys].[systypes] sst
	ON	s.[system_type_id] = sst.[xtype]
	AND	s.[user_type_id] = sst.[xusertype]
WHERE	s.[object_id] = OBJECT_ID(''' + @QualifiedTable + ''')
AND		t.[object_id] = OBJECT_ID(''' + @QualifiedToTable + ''')
ORDER BY s.[column_id]'	
    )
END