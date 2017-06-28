/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE function [admin].[GetForeignKeyStatement] 
(
	 @Catalog				NVARCHAR(128)
	,@QualifiedTable		NVARCHAR(500)
) 
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN 
    (   SELECT 'USE [' + @Catalog + ']
SELECT	 QUOTENAME(SCHEMA_NAME(fk.[schema_id])) + ''.'' + QUOTENAME(OBJECT_NAME(fk.[parent_object_id]))
		,QUOTENAME(fk.[name])
		,QUOTENAME(SCHEMA_NAME(so.[schema_id])) + ''.'' + QUOTENAME(so.[name])
		,QUOTENAME(sc.[name])
		,QUOTENAME(rsc.[name])
		,CASE 
			WHEN OBJECTPROPERTY(fk.[object_id], ''CnstIsUpdateCascade'') = 1 THEN '' ON UPDATE CASCADE''
			WHEN OBJECTPROPERTY(fk.[object_id], ''CnstIsDeleteCascade'') = 1 THEN '' ON DELETE CASCADE''
			ELSE ''''
		END
		,''ALTER TABLE <<ParentTable>> DROP CONSTRAINT <<ForeignKeyConstraint>>;''
		,''ALTER TABLE <<ParentTable>> WITH CHECK ADD CONSTRAINT <<ForeignKeyConstraint>> FOREIGN KEY(<<ForeignKeyColumn>>) REFERENCES <<ReferenceTable>>(<<ReferenceColumn>>)<<ConstraintCascade>>;''
FROM	[sys].[foreign_keys] fk
INNER JOIN [sys].[foreign_key_columns] fkc
	ON	fk.[object_id] = fkc.[constraint_object_id]
INNER JOIN [sys].[columns] sc
	ON	fkc.[parent_object_id] = sc.[object_id]
	AND	fkc.[parent_column_id] = sc.[column_id]
INNER JOIN [sys].[objects] so
	ON	fk.[referenced_object_id] = so.[object_id]
INNER JOIN [sys].[columns] rsc
	ON	fkc.[referenced_object_id] = rsc.[object_id]
	AND	fkc.[referenced_column_id] = rsc.[column_id]
WHERE	fk.[referenced_object_id] = OBJECT_ID(''' + @QualifiedTable + ''')'
    )
END