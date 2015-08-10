/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogExecution](
	@ExecutionGUID			[nvarchar](40),
	@SourceGUID				[nvarchar](40),
	@PackageName			[varchar](500),
	@ParentSourceGUID		[nvarchar](40),
	@ParentExecutionID		[int],
	@ServerExecutionID		[bigint],
	@ExecutionID			[int]         = NULL OUTPUT
) 
AS 

SELECT  @ExecutionID = MAX([ExecutionID])
FROM    [ssis].[Execution]
WHERE   [SourceGUID] = REPLACE(REPLACE(@SourceGUID, '{', ''), '}', '')
AND		[ExecutionGUID] = REPLACE(REPLACE(@ExecutionGUID, '{', ''), '}', '')
AND		[ParentExecutionID] = ISNULL(@ParentExecutionID, -1);

IF @ExecutionID IS NULL
BEGIN
	INSERT INTO [ssis].[Execution]
			([ParentExecutionID]
			,[ExecutionGUID]
			,[SourceGUID]
			--,[PackageName]
			,[ParentSourceGUID]
			,[ServerExecutionID])
	VALUES	(ISNULL(@ParentExecutionID, -1)
			,REPLACE(REPLACE(@ExecutionGUID, '{', ''), '}', '')
			,REPLACE(REPLACE(@SourceGUID, '{', ''), '}', '')
			--,ISNULL(@PackageName, 'Not Sepcified')
			,ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '')
			,@ServerExecutionID);

	SELECT  @ExecutionID = SCOPE_IDENTITY();
END

IF ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '') <> ''
BEGIN
	UPDATE	[ssis].[Execution]
	SET		[ParentSourceGUID] = REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', '')
	WHERE	[ExecutionID] = @ExecutionID
END

