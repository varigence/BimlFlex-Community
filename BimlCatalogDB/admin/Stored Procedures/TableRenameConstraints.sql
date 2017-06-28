/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [admin].[TableRenameConstraints]
	 @Catalog				NVARCHAR(128)
	,@Schema				NVARCHAR(128)
	,@Table					NVARCHAR(128)
AS
SET NOCOUNT ON
BEGIN
	DECLARE  @QualifiedTable		NVARCHAR(500)
			,@SqlExec				NVARCHAR(MAX)
			,@NL					VARCHAR(2)
			,@RC					INT

	SET		@NL = CHAR(13) + CHAR(10);
	SELECT	@QualifiedTable = '[' + @Catalog + '].[' + @Schema + '].[' + @Table + ']';

	DECLARE @tblRename TABLE([SqlExec]	NVARCHAR(MAX));

	SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
			+ 'SELECT	''ALTER TABLE '' + ''' + @QualifiedTable + ''' + '' DROP CONSTRAINT ['' + dc.[name] + '']; ''
					+ ''ALTER TABLE '' + ''' + @QualifiedTable + ''' + '' ADD CONSTRAINT [DF_'' + SCHEMA_NAME(dc.[schema_id]) + OBJECT_NAME(dc.[parent_object_id]) 
					+ ''_'' + COL_NAME(dc.[parent_object_id], dc.[parent_column_id]) + ''] DEFAULT '' + dc.[definition] + '' FOR ['' 
					+ COL_NAME(dc.[parent_object_id], dc.[parent_column_id]) + ''];''
			FROM	[sys].[default_constraints] dc
			WHERE	dc.[parent_object_id] = OBJECT_ID(''' + @QualifiedTable + ''');';
	INSERT	@tblRename EXEC (@SqlExec);
	
	SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
			+ 'SELECT	''EXEC sp_rename N''''' + @QualifiedTable + '.['' + so.[name] + '']'''', N'''
						+ '''PK'' + CASE INDEXPROPERTY(so.[parent_object_id], so.[name], ''IsClustered'') WHEN 1 THEN ''C_'' ELSE ''N_'' END 
						+ SCHEMA_NAME(so.[schema_id]) + OBJECT_NAME(so.[parent_object_id]) + '''''', N''''INDEX''''''
				FROM	[sys].[objects] so
				WHERE	OBJECTPROPERTY(so.[object_id] ,''IsPrimaryKey'')  = 1
				AND		so.[parent_object_id] = OBJECT_ID(''' + @QualifiedTable + ''');';
	--PRINT	@SqlExec;
	INSERT	@tblRename EXEC (@SqlExec);
	
	DECLARE crsRenameDefaults CURSOR FOR
	SELECT	'USE [' + @Catalog + ']' + @NL + [SqlExec]
	FROM	@tblRename;

	OPEN crsRenameDefaults;
	FETCH NEXT FROM crsRenameDefaults INTO @SqlExec;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@SqlExec);
		FETCH NEXT FROM crsRenameDefaults INTO @SqlExec;
	END
	CLOSE crsRenameDefaults;
	DEALLOCATE crsRenameDefaults;
	
END