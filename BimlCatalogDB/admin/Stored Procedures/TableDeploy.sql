/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [admin].[TableDeploy]
	 @Catalog				NVARCHAR(128)
	,@Schema				NVARCHAR(128)
	,@Table					NVARCHAR(128)
	,@ToSchema				NVARCHAR(128) = NULL	
	,@ToTable				NVARCHAR(128) = NULL
	,@BackupSchema			NVARCHAR(128) = NULL
AS

SET NOCOUNT ON
DECLARE  @QualifiedToTable	NVARCHAR(512)
		,@QualifiedTable	NVARCHAR(512)
		,@BackupTable		NVARCHAR(512)
		,@SqlExec			NVARCHAR(MAX)
		,@NL				VARCHAR(2)			= CHAR(13) + CHAR(10)
		,@RC				INT

SET		@ToSchema = ISNULL(@ToSchema, 'copy')
SET		@ToTable = ISNULL(@ToTable, @Table)
SET		@QualifiedToTable = '[' + @Catalog + '].[' + @ToSchema + '].[' + @ToTable + ']'
SET		@QualifiedTable = '[' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
SET		@BackupTable = '[' + @Catalog + '].[backup].[' + @Table + ']'

SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
		+ 'IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''backup'') EXEC (''CREATE SCHEMA [backup] AUTHORIZATION [dbo]'')'
EXEC	(@SqlExec)
SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
		+ 'IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''copy'') EXEC (''CREATE SCHEMA [copy] AUTHORIZATION [dbo]'')'
EXEC	(@SqlExec)
SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
		+ 'IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @Schema + ''') EXEC (''CREATE SCHEMA [' + @Schema + '] AUTHORIZATION [dbo]'')'
EXEC	(@SqlExec)

DECLARE @tblConstraints	TABLE(
		[ParentTable]			[nvarchar](512),
		[ForeignKeyConstraint]	[nvarchar](512),
		[ReferenceTable]		[nvarchar](512),
		[ForeignKeyColumn]		[nvarchar](512),
		[ReferenceColumn]		[nvarchar](512),
		[ConstraintCascade]		[nvarchar](128),
		[DropPattern]			[nvarchar](256),
		[CreatePattern]			[nvarchar](256))

IF OBJECT_ID(@BackupTable) IS NOT NULL
BEGIN 
	EXEC ('DROP TABLE ' + @BackupTable)
END

IF OBJECT_ID(@QualifiedTable) IS NULL
BEGIN
	SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
			+ 'ALTER SCHEMA [' + @Schema + '] TRANSFER [' + @ToSchema + '].[' + @ToTable + ']'
	EXEC (@SqlExec)
END
ELSE
BEGIN
	EXEC @RC = [admin].[TableCompare] @Catalog, @Schema, @Table, @ToSchema, @ToTable

	IF ISNULL(@RC, -1) = -1		-- Table changes detected
	BEGIN
		EXEC @RC = [admin].[TableCopy] @Catalog, @Schema, @Table, @ToSchema, @ToTable

		SET	@SqlExec = [admin].[GetForeignKeyStatement](@Catalog, @QualifiedTable)
		INSERT INTO @tblConstraints EXEC (@SqlExec)

		BEGIN TRY
			BEGIN TRANSACTION;	
					
			IF OBJECT_ID(@QualifiedTable) IS NOT NULL
			BEGIN
				DECLARE crsDropConstraints CURSOR FOR
				SELECT	'USE [' + @Catalog + ']' + @NL + REPLACE(REPLACE([DropPattern], '<<ParentTable>>', [ParentTable]), '<<ForeignKeyConstraint>>', [ForeignKeyConstraint])
				FROM	@tblConstraints

				OPEN crsDropConstraints
				FETCH NEXT FROM crsDropConstraints INTO @SqlExec
				WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC (@SqlExec)
					FETCH NEXT FROM crsDropConstraints INTO @SqlExec
				END
				CLOSE crsDropConstraints
				DEALLOCATE crsDropConstraints
				
				-- ALTER SCHEMA [backup]				
				SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL
						+ 'ALTER SCHEMA [backup] TRANSFER [' + @Schema + '].[' + @Table + ']'
				EXEC (@SqlExec)
			END		
														
			-- ALTER SCHEMA @Schema
			SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
					+ 'ALTER SCHEMA [' + @Schema + '] TRANSFER [' + @ToSchema + '].[' + @ToTable + ']'
			EXEC (@SqlExec)
			
			DECLARE crsAddConstraints CURSOR FOR
			SELECT	'USE [' + @Catalog + ']' + @NL +
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE([CreatePattern], '<<ParentTable>>', [ParentTable])
									, '<<ForeignKeyConstraint>>', [ForeignKeyConstraint])
								,'<<ForeignKeyColumn>>', [ForeignKeyColumn])
							,'<<ReferenceTable>>', [ReferenceTable])
						,'<<ReferenceColumn>>', [ReferenceColumn])
					,'<<ConstraintCascade>>', [ConstraintCascade])
			FROM	@tblConstraints

			OPEN crsAddConstraints
			FETCH NEXT FROM crsAddConstraints INTO @SqlExec
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC (@SqlExec)
				FETCH NEXT FROM crsAddConstraints INTO @SqlExec
			END
			CLOSE crsAddConstraints
			DEALLOCATE crsAddConstraints

			COMMIT TRANSACTION;

			IF OBJECT_ID(@BackupTable) IS NOT NULL
			BEGIN 
				SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
						+ 'DROP TABLE [backup].[' + @Table + ']'
				EXEC (@SqlExec)			
			END
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

		RETURN 0
	END
--	ELSE IF ISNULL(@RC, -1) = -2		-- PRIMARY KEY CHANGES DETECTED
--	BEGIN
--
--	END
	ELSE
	BEGIN
		IF OBJECT_ID(@QualifiedToTable) IS NOT NULL
		BEGIN 
			SET		@SqlExec = 'USE [' + @Catalog + ']' + @NL 
					+ 'DROP TABLE ' + @QualifiedToTable
			EXEC (@SqlExec)			
		END
	END
END