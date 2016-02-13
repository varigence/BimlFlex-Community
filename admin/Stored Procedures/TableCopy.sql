/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [admin].[TableCopy]
	 @Catalog				NVARCHAR(128)
	,@Schema				NVARCHAR(128)
	,@Table					NVARCHAR(128)
	,@ToSchema				NVARCHAR(128) = NULL	
	,@ToTable				NVARCHAR(128) = NULL
	,@DropToTable			BIT = 0
	,@TruncToTable			BIT = 1
AS
SET NOCOUNT ON
BEGIN
	DECLARE  @QualifiedToTable		NVARCHAR(500)
			,@QualifiedTable		NVARCHAR(500)
			,@SqlColumnList			VARCHAR(MAX)
			,@SqlColumnsSelect		VARCHAR(MAX)
			,@SqlExec				NVARCHAR(MAX)
			,@NL					VARCHAR(2)
			,@RC					INT

	SET		@NL = VARCHAR(13) + VARCHAR(10)
	SET		@ToSchema = ISNULL(@ToSchema, 'copy')
	SET		@ToTable = ISNULL(@ToTable, @Table)
	SELECT	@QualifiedToTable = '[' + @Catalog + '].[' + @ToSchema + '].[' + @ToTable + ']'
	SELECT	@QualifiedTable = '[' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
	IF OBJECT_ID(@QualifiedTable) IS NOT NULL
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;			

			IF OBJECT_ID(@QualifiedToTable) IS NOT NULL AND (@TruncToTable = 1)
			BEGIN 
				EXEC ('TRUNCATE TABLE ' + @QualifiedToTable)
			END
			ELSE IF OBJECT_ID(@QualifiedToTable) IS NOT NULL AND (@DropToTable = 1)
			BEGIN 
				EXEC ('DROP TABLE ' + @QualifiedToTable)
			END

			-- Create Default ToTable if it is missing
			IF OBJECT_ID(@QualifiedToTable) IS NULL
			BEGIN
				SET		@SqlExec = 'SELECT * INTO ' + @QualifiedToTable + ' FROM ' + @QualifiedTable + ' WHERE 1=2'
				EXEC	(@SqlExec)		
			END
				
			DECLARE  @ColumnName		NVARCHAR(128)
					,@FromDataType		NVARCHAR(128)
					,@ToDataType		NVARCHAR(128)
					,@ToMaxLength		VARCHAR(10)
					,@ToPrecision		VARCHAR(10)
					,@ToScale			VARCHAR(10)
				
			-- Get the column info
			DECLARE @tblColumns TABLE ( 
					[ColumnName]		NVARCHAR(128),
					[FromDataType]		NVARCHAR(128),
					[ToDataType]		NVARCHAR(128),
					[ToMaxLength]		VARCHAR(10),
					[ToPrecision]		VARCHAR(10),
					[ToScale]			VARCHAR(10))
				
			SET		@SqlExec = [admin].[GetColumnListStatement](@Catalog, @QualifiedToTable, @QualifiedTable)
			--PRINT	@SqlExec
			INSERT INTO @tblColumns EXEC (@SqlExec)						

			-- Create Cursor for all common columns
			DECLARE crsColumns CURSOR FOR 
			SELECT	 [ColumnName]
					,[FromDataType]
					,[ToDataType]
					,[ToMaxLength]
					,[ToPrecision]
					,[ToScale]
			FROM	@tblColumns	

			OPEN crsColumns
			FETCH NEXT FROM crsColumns INTO @ColumnName, @FromDataType, @ToDataType, @ToMaxLength, @ToPrecision, @ToScale

			SET		@SqlColumnList = ''
			SET		@SqlColumnsSelect = ''
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET		@SqlColumnList = @SqlColumnList + ',' + @ColumnName	
				SET		@SqlColumnsSelect = @SqlColumnsSelect + ',' + 
						(SELECT CASE @FromDataType
							WHEN @ToDataType THEN @ColumnName
							ELSE		
								'CAST(' + @ColumnName + ' AS ' +
								CASE @ToDataType
									WHEN 'money' THEN 'money(' + @ToPrecision + ','+ @ToScale+ ')'
									WHEN 'decimal' THEN 'decimal(' + @ToPrecision + ','+ @ToScale+ ')'
									WHEN 'numeric' THEN 'numeric(' + @ToPrecision + ','+ @ToScale+ ')'
									WHEN 'smallmoney' THEN 'smallmoney(' + @ToPrecision + ','+ @ToScale+ ')'
									WHEN 'varbinary' THEN 'varbinary(' + @ToMaxLength + ')'
									WHEN 'varchar' THEN 'varchar(' + @ToMaxLength + ')'
									WHEN 'binary' THEN 'binary(' + @ToMaxLength + ')'
									WHEN 'VARCHAR' THEN 'VARCHAR(' + @ToMaxLength + ')'
									WHEN 'nvarchar' THEN 'nvarchar(' + @ToMaxLength + ')'
									WHEN 'nchar' THEN 'nchar(' + @ToMaxLength + ')'
									ELSE @ToDataType
								END + ') AS ' + @ColumnName
							END)
				FETCH NEXT FROM crsColumns INTO @ColumnName, @FromDataType, @ToDataType, @ToMaxLength, @ToPrecision, @ToScale
			END
			CLOSE crsColumns
			DEALLOCATE crsColumns

			-- Trim the leading commas
			SET 	@SqlColumnList = RIGHT(@SqlColumnList, LEN(@SqlColumnList) - 1)
			SET		@SqlColumnsSelect = RIGHT(@SqlColumnsSelect, LEN(@SqlColumnsSelect) - 1)
			SET		@SqlExec = 'USE [' + @Catalog + '] SELECT OBJECTPROPERTY(OBJECT_ID(N''' + @QualifiedToTable + '''), N''TableHasIdentity'')'
			
			DECLARE @HasIdentity INT
			DECLARE @tblHasIdentity TABLE ([HasIdentity]	INT)
							
			INSERT INTO @tblHasIdentity
			EXEC	(@SqlExec)
					
			SELECT	@HasIdentity = ISNULL([HasIdentity], 0)
			FROM	@tblHasIdentity
					
			-- Build the copy sql
			SET		@SqlExec = 'INSERT INTO ' + @QualifiedToTable + '(' + @SqlColumnList + ') ' +  @NL 
					+ 'SELECT ' + @SqlColumnsSelect + @NL
					+ 'FROM ' + @QualifiedTable

			-- If identity append the SET IDENTITY_INSERT commands
			IF @HasIdentity = 1
					SET		@SqlExec = 'SET IDENTITY_INSERT ' + @QualifiedToTable + ' ON ;' +  @NL 
							+ ' ' +  @SqlExec + '; ' +  @NL + 'SET IDENTITY_INSERT ' + @QualifiedToTable + ' OFF'

			EXEC	(@SqlExec)

			COMMIT TRANSACTION;			

		END TRY

		BEGIN CATCH
			SELECT	ERROR_NUMBER()	AS [ErrorNumber],
					ERROR_MESSAGE() AS [ErrorMessage];

			-- Test if the transaction is uncommittable.
			IF (XACT_STATE()) = -1
			BEGIN
				PRINT	N'The transaction is in an uncommittable state. ' +
						'Rolling back transaction.'
				ROLLBACK TRANSACTION;
			END;

			-- Test if the transaction is active and valid.
			IF (XACT_STATE()) = 1
			BEGIN
				PRINT	N'The transaction is committable. ' +
						'Committing transaction.'
				COMMIT TRANSACTION;   
			END;
			RETURN	ERROR_NUMBER();
		END CATCH;
	END
	RETURN 0
END