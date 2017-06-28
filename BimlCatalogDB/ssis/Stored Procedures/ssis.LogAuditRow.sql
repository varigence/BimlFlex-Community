/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogAuditRow]
    @ExecutionID			[bigint],
    @ComponentName			[nvarchar](200),
    @ObjectName				[nvarchar](200),
    @AuditType				[varchar](20),
    @RowCount				[int],
    @AuditRowSchema			[xml],
	@AuditRowData			[AuditRowDataType] READONLY
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE	 @AuditRowID				BIGINT


    INSERT INTO [ssis].[AuditRow]
        ([ExecutionID]
        ,[ComponentName]
        ,[ObjectName]
        ,[AuditType]
        ,[RowCount]
        ,[AuditRowSchema])
    VALUES
        (@ExecutionID
        ,@ComponentName
        ,@ObjectName
        ,@AuditType
        ,@RowCount
        ,@AuditRowSchema);

	SELECT @AuditRowID = SCOPE_IDENTITY();

	INSERT INTO [ssis].[AuditRowData]
			([AuditRowID]
			,[RowID]
			,[ColumnName]
			,[ColumnValue])
     SELECT	 @AuditRowID	
			,[RowID]
			,[ColumnName]
			,[ColumnValue]
	FROM	@AuditRowData


	RETURN(0);
END TRY

BEGIN CATCH
    RETURN ERROR_NUMBER();
END CATCH;