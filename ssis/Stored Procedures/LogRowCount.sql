/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogRowCount](
    @ExecutionID			[bigint],
    @ComponentName			[nvarchar](200),
    @ObjectName				[nvarchar](200),
    @CountType				[varchar](20),
    @RowCount				[int],
	@ColumnSum				[money],
	@ColumnName				[varchar](200)
) 
AS
BEGIN TRY
	
    INSERT INTO [ssis].[RowCount]
        ([ExecutionID]
        ,[ComponentName]
        ,[ObjectName]
        ,[CountType]
        ,[RowCount]
		,[ColumnSum]
		,[ColumnName])
    VALUES
        (@ExecutionID
        ,@ComponentName
        ,@ObjectName
        ,@CountType
        ,@RowCount
		,@ColumnSum
		,@ColumnName);

	RETURN(0);
END TRY

BEGIN CATCH
    RETURN ERROR_NUMBER();
END CATCH;