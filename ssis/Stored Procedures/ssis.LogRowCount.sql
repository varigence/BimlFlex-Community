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
	
  --  INSERT INTO [ssis].[RowCount]
  --      ([ExecutionID]
  --      ,[ComponentName]
  --      ,[ObjectName]
  --      ,[CountType]
  --      ,[RowCount]
		--,[ColumnSum]
		--,[ColumnName])
  --  VALUES
  --      (@ExecutionID
  --      ,@ComponentName
  --      ,@ObjectName
  --      ,@CountType
  --      ,@RowCount
		--,@ColumnSum
		--,@ColumnName);

	MERGE [ssis].[RowCount] AS TARGET
	USING 
	(
		SELECT	 @ExecutionID AS [ExecutionID]
				,@ComponentName AS [ComponentName]
				,@ObjectName AS [ObjectName]
				,@CountType AS [CountType]
				,@RowCount AS [RowCount]
				,@ColumnSum AS [ColumnSum]
				,@ColumnName AS [ColumnName]
	) AS SOURCE
		ON	TARGET.[ExecutionID] = SOURCE.[ExecutionID] 
		AND	TARGET.[ComponentName] = SOURCE.[ComponentName] COLLATE Latin1_General_CS_AS
		AND	TARGET.[ObjectName] = SOURCE.[ObjectName] COLLATE Latin1_General_CS_AS
		AND	TARGET.[CountType] = SOURCE.[CountType] COLLATE Latin1_General_CS_AS
	WHEN MATCHED THEN 
		UPDATE 
		SET		 [RowCount] = SOURCE.[RowCount]
				,[ColumnSum] = SOURCE.[ColumnSum]
				,[ColumnName] = SOURCE.[ColumnName]
	WHEN NOT MATCHED THEN
		INSERT	([ExecutionID]
				,[ComponentName]
				,[ObjectName]
				,[CountType]
				,[RowCount]
				,[ColumnSum]
				,[ColumnName])
		VALUES	(SOURCE.[ExecutionID]
				,SOURCE.[ComponentName]
				,SOURCE.[ObjectName]
				,SOURCE.[CountType]
				,SOURCE.[RowCount]
				,SOURCE.[ColumnSum]
				,SOURCE.[ColumnName]);

	RETURN(0);
END TRY

BEGIN CATCH
    RETURN ERROR_NUMBER();
END CATCH;