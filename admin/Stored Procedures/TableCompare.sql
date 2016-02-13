/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [admin].[TableCompare]
	 @Catalog			NVARCHAR(128)
	,@Schema			NVARCHAR(128)
	,@Table				NVARCHAR(128)
	,@ToSchema			NVARCHAR(128)
	,@ToTable			NVARCHAR(128)
AS
SET NOCOUNT ON
DECLARE  @DiffCount		INT
		,@SqlExec		NVARCHAR(MAX)
		,@NL			VARCHAR(2)			= VARCHAR(13) + VARCHAR(10)

CREATE TABLE #SourceColumns(
	[TABLE_CATALOG]				[nvarchar](128),
	[TABLE_SCHEMA]				[nvarchar](128),
	[TABLE_NAME]				[nvarchar](128),
	[COLUMN_NAME]				[nvarchar](128),
	[ORDINAL_POSITION]			[int],
	[COLUMN_DEFAULT]			[nvarchar](4000),
	[IS_NULLABLE]				[varchar](3),
	[DATA_TYPE]					[nvarchar](128),
	[CHARACTER_MAXIMUM_LENGTH]	[int],
	[CHARACTER_OCTET_LENGTH]	[int],
	[NUMERIC_PRECISION]			[tinyint],
	[NUMERIC_PRECISION_RADIX]	[smallint],
	[NUMERIC_SCALE]				[int],
	[DATETIME_PRECISION]		[smallint],
	[CHARACTER_SET_CATALOG]		[nvarchar](128),
	[CHARACTER_SET_SCHEMA]		[nvarchar](128),
	[CHARACTER_SET_NAME]		[nvarchar](128),
	[COLLATION_CATALOG]			[nvarchar](128),
	[COLLATION_SCHEMA]			[nvarchar](128),
	[COLLATION_NAME]			[nvarchar](128),
	[DOMAIN_CATALOG]			[nvarchar](128),
	[DOMAIN_SCHEMA]				[nvarchar](128),
	[DOMAIN_NAME]				[nvarchar](128),
	[IsIdentity]				[tinyint])

CREATE TABLE #CurrentColumns(
	[TABLE_CATALOG]				[nvarchar](128),
	[TABLE_SCHEMA]				[nvarchar](128),
	[TABLE_NAME]				[nvarchar](128),
	[COLUMN_NAME]				[nvarchar](128),
	[ORDINAL_POSITION]			[int],
	[COLUMN_DEFAULT]			[nvarchar](4000),
	[IS_NULLABLE]				[varchar](3),
	[DATA_TYPE]					[nvarchar](128),
	[CHARACTER_MAXIMUM_LENGTH]	[int],
	[CHARACTER_OCTET_LENGTH]	[int],
	[NUMERIC_PRECISION]			[tinyint],
	[NUMERIC_PRECISION_RADIX]	[smallint],
	[NUMERIC_SCALE]				[int],
	[DATETIME_PRECISION]		[smallint],
	[CHARACTER_SET_CATALOG]		[nvarchar](128),
	[CHARACTER_SET_SCHEMA]		[nvarchar](128),
	[CHARACTER_SET_NAME]		[nvarchar](128),
	[COLLATION_CATALOG]			[nvarchar](128),
	[COLLATION_SCHEMA]			[nvarchar](128),
	[COLLATION_NAME]			[nvarchar](128),
	[DOMAIN_CATALOG]			[nvarchar](128),
	[DOMAIN_SCHEMA]				[nvarchar](128),
	[DOMAIN_NAME]				[nvarchar](128),
	[IsIdentity]				[tinyint])

SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
		+ 'SELECT	* ' + @NL
		+ '		,COLUMNPROPERTY(OBJECT_ID(''[' + @Schema + '].[' + @Table + ']''), [COLUMN_NAME], ''IsIdentity'') AS [IsIdentity]' + @NL
		+ 'FROM	[INFORMATION_SCHEMA].[COLUMNS]' + @NL
		+ 'WHERE	[TABLE_CATALOG] = ''' + @Catalog + '''' + @NL
		+ 'AND		[TABLE_SCHEMA] = ''' + @Schema + '''' + @NL
		+ 'AND		[TABLE_NAME] = ''' + @Table + ''''


INSERT #CurrentColumns
EXEC (@SqlExec)

SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
		+ 'SELECT	* ' + @NL
		+ '		,COLUMNPROPERTY(OBJECT_ID(''[' + @ToSchema + '].[' + @ToTable + ']''), [COLUMN_NAME], ''IsIdentity'') AS [IsIdentity]' + @NL
		+ 'FROM	[INFORMATION_SCHEMA].[COLUMNS]' + @NL
		+ 'WHERE	[TABLE_CATALOG] = ''' + @Catalog + '''' + @NL
		+ 'AND		[TABLE_SCHEMA] = ''' + @ToSchema + '''' + @NL
		+ 'AND		[TABLE_NAME] = ''' + @ToTable + ''''

INSERT #SourceColumns
EXEC (@SqlExec)

SELECT	@DiffCount = COUNT(*)
FROM	#CurrentColumns o
FULL OUTER JOIN #SourceColumns n
	ON	ISNULL(o.[COLUMN_NAME], '') = ISNULL(n.[COLUMN_NAME], '')
WHERE	NOT (	ISNULL(o.[ORDINAL_POSITION], 0) = ISNULL(n.[ORDINAL_POSITION], 0)
		AND	ISNULL(o.[COLUMN_DEFAULT], '') = ISNULL(n.[COLUMN_DEFAULT], '')
		AND	ISNULL(o.[IS_NULLABLE], '') = ISNULL(n.[IS_NULLABLE], '')
		AND	ISNULL(o.[DATA_TYPE], '') = ISNULL(n.[DATA_TYPE], '')
		AND	ISNULL(o.[CHARACTER_MAXIMUM_LENGTH], 0) = ISNULL(n.[CHARACTER_MAXIMUM_LENGTH], 0)
		AND	ISNULL(o.[CHARACTER_OCTET_LENGTH], 0) = ISNULL(n.[CHARACTER_OCTET_LENGTH], 0)
		AND	ISNULL(o.[NUMERIC_PRECISION], 0) = ISNULL(n.[NUMERIC_PRECISION], 0)
		AND	ISNULL(o.[NUMERIC_PRECISION_RADIX], 0) = ISNULL(n.[NUMERIC_PRECISION_RADIX], 0)
		AND	ISNULL(o.[NUMERIC_SCALE], 0) = ISNULL(n.[NUMERIC_SCALE], 0)
		AND	ISNULL(o.[DATETIME_PRECISION], 0) = ISNULL(n.[DATETIME_PRECISION], 0)
		AND	ISNULL(o.[CHARACTER_SET_CATALOG], '') = ISNULL(n.[CHARACTER_SET_CATALOG], '')
		AND	ISNULL(o.[CHARACTER_SET_SCHEMA], '') = ISNULL(n.[CHARACTER_SET_SCHEMA], '')
		AND	ISNULL(o.[CHARACTER_SET_NAME], '') = ISNULL(n.[CHARACTER_SET_NAME], '')
		AND	ISNULL(o.[COLLATION_CATALOG], '') = ISNULL(n.[COLLATION_CATALOG], '')
		AND	ISNULL(o.[COLLATION_SCHEMA], '') = ISNULL(n.[COLLATION_SCHEMA], '')
		AND	ISNULL(o.[COLLATION_NAME], '') = ISNULL(n.[COLLATION_NAME], '')
		AND	ISNULL(o.[DOMAIN_CATALOG], '') = ISNULL(n.[DOMAIN_CATALOG], '')
		AND	ISNULL(o.[DOMAIN_SCHEMA], '') = ISNULL(n.[DOMAIN_SCHEMA], '')
		AND	ISNULL(o.[DOMAIN_NAME], '') = ISNULL(n.[DOMAIN_NAME], '')
		AND	ISNULL(o.[IsIdentity], 0) = ISNULL(n.[IsIdentity], 0))

IF @DiffCount > 0 
BEGIN
	RETURN -1
END
ELSE
BEGIN
	DELETE FROM #CurrentColumns
	DELETE FROM #SourceColumns

	SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
			+ 'SELECT	c.[TABLE_CATALOG],c.[TABLE_SCHEMA],c.[TABLE_NAME],c.[COLUMN_NAME],c.[ORDINAL_POSITION]' + @NL
			+ 'FROM	[INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] p' + @NL
			+ 'INNER JOIN [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] c' + @NL
			+ '	ON	c.[TABLE_SCHEMA] = p.[TABLE_SCHEMA]' + @NL
			+ '	AND	c.[TABLE_NAME] = p.[TABLE_NAME]' + @NL
			+ '	AND	c.[CONSTRAINT_NAME] = p.[CONSTRAINT_NAME]' + @NL
			+ 'WHERE	p.[CONSTRAINT_TYPE] = ''PRIMARY KEY''' + @NL
			+ 'AND		p.[TABLE_CATALOG] = ''' + @Catalog + '''' + @NL
			+ 'AND		p.[TABLE_SCHEMA] = ''' + @Schema + '''' + @NL
			+ 'AND		p.[TABLE_NAME] = ''' + @Table + ''''

	INSERT INTO #CurrentColumns([TABLE_CATALOG],[TABLE_SCHEMA],[TABLE_NAME],[COLUMN_NAME],[ORDINAL_POSITION])
	EXEC (@SqlExec)


	SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
			+ 'SELECT	c.[TABLE_CATALOG],c.[TABLE_SCHEMA],c.[TABLE_NAME],c.[COLUMN_NAME],c.[ORDINAL_POSITION]' + @NL
			+ 'FROM	[INFORMATION_SCHEMA].[TABLE_CONSTRAINTS] p' + @NL
			+ 'INNER JOIN [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] c' + @NL
			+ '	ON	c.[TABLE_SCHEMA] = p.[TABLE_SCHEMA]' + @NL
			+ '	AND	c.[TABLE_NAME] = p.[TABLE_NAME]' + @NL
			+ '	AND	c.[CONSTRAINT_NAME] = p.[CONSTRAINT_NAME]' + @NL
			+ 'WHERE	p.[CONSTRAINT_TYPE] = ''PRIMARY KEY''' + @NL
			+ 'AND		p.[TABLE_CATALOG] = ''' + @Catalog + '''' + @NL
			+ 'AND		p.[TABLE_SCHEMA] = ''' + @ToSchema + '''' + @NL
			+ 'AND		p.[TABLE_NAME] = ''' + @ToTable + ''''

	INSERT INTO #SourceColumns([TABLE_CATALOG],[TABLE_SCHEMA],[TABLE_NAME],[COLUMN_NAME],[ORDINAL_POSITION])
	EXEC (@SqlExec)

	SELECT	@DiffCount = COUNT(*)
	FROM	#CurrentColumns o
	FULL OUTER JOIN #SourceColumns n
		ON	ISNULL(o.[COLUMN_NAME], '') = ISNULL(n.[COLUMN_NAME], '')
	WHERE	ISNULL(o.[ORDINAL_POSITION], 0) <> ISNULL(n.[ORDINAL_POSITION], 0)

	IF @DiffCount > 0 
		RETURN -2
	ELSE
		RETURN 0
END