/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogColumnInfo](
	@ExecutionID			[bigint],
	@InputColumnInfo		[InputColumnInfo] READONLY
) 
AS 

DECLARE	 @PackageID				INT

SELECT	 @PackageID = [PackageID]
FROM	[ssis].[Execution] 
WHERE	[ExecutionID] = @ExecutionID

BEGIN
		INSERT INTO [ssis].[ColumnInfo]
			   ([PackageID]
			   ,[LineageID]
			   ,[ColumnName]
			   ,[CodePage]
			   ,[DataType]
			   ,[Length]
			   ,[Precision]
			   ,[Scale])
		SELECT   @PackageID AS [PackageID]
				,[LineageID]
				,[Name] AS [ColumnName]
				,[CodePage]
				,[DataType]
				,[Length]
				,[Precision]
				,[Scale]
		FROM	@InputColumnInfo

/*

	MERGE [ssis].[ColumnInfo] AS TARGET
	USING 
	(	
		SELECT   @PackageID AS [PackageID]
				,[LineageID]
				,[Name] AS [ColumnName]
				,[CodePage]
				,[DataType]
				,[Length]
				,[Precision]
				,[Scale]
		FROM	@InputColumnInfo
	) AS src
		ON	TARGET.[PackageID] = src.[PackageID]
		AND	TARGET.[LineageID] = src.[LineageID]
		AND	TARGET.[ColumnName] = src.[ColumnName]
	WHEN NOT MATCHED THEN
		INSERT	([PackageID]
				,[LineageID]
				,[ColumnName]
				,[CodePage]
				,[DataType]
				,[Length]
				,[Precision]
				,[Scale])
		VALUES	(src.[PackageID]
				,src.[LineageID]
				,src.[ColumnName]
				,src.[CodePage]
				,src.[DataType]
				,src.[Length]
				,src.[Precision]
				,src.[Scale]);
*/
END

