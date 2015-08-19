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
	@IsBatch				[bit],
	@ParentSourceGUID		[nvarchar](40),
	@ParentExecutionID		[bigint],
	@ServerExecutionID		[bigint],
	@ExecutionID			[bigint]        = NULL OUTPUT,
	@ExecutionStatus		[char](1)		= NULL OUTPUT
) 
AS 

DECLARE	 @PackageID				INT
		,@CurrentExecutionID	BIGINT
		,@IsEnabled				BIT

SELECT  @ExecutionID = MAX([ExecutionID])
FROM    [ssis].[Execution]
WHERE   [SourceGUID] = REPLACE(REPLACE(@SourceGUID, '{', ''), '}', '')
AND		[ExecutionGUID] = REPLACE(REPLACE(@ExecutionGUID, '{', ''), '}', '')
AND		[ParentExecutionID] = @ParentExecutionID;

IF @ExecutionID IS NULL
BEGIN
	SELECT	 @PackageID = [PackageID]
			,@IsEnabled = [IsEnabled]
	FROM	[ssis].[Package]
	WHERE	[PackageName] = @PackageName

	IF @PackageID IS NULL
	BEGIN
		INSERT INTO [ssis].[Package] ([PackageName], [IsBatch]) VALUES (@PackageName, @IsBatch)
		SELECT @PackageID = SCOPE_IDENTITY();
	END

	-- Check if Package is already executing
	SELECT	 @CurrentExecutionID = [ExecutionID]
			,@ExecutionStatus = [ExecutionStatus]
	FROM	[ssis].[Execution]
	WHERE	[ExecutionID] = 
		(
			SELECT	MAX([ExecutionID])
			FROM	[ssis].[Execution]
			WHERE	[PackageID] = @PackageID
		)

	-- If the package is currently executing or disabled abort the process.
	IF ISNULL(@ExecutionStatus, 'S') = 'E' OR  @IsEnabled = 0 -- Executing or Disabled
	BEGIN
		IF @ExecutionStatus <> 'E' SET @ExecutionStatus = 'A' -- Abort this instance
	END
	ELSE 
	BEGIN
		-- If the previous execution failed innitiate rollback process.
		IF ISNULL(@ExecutionStatus, 'S') = 'F' -- Failed - Rollback
			SET		@ExecutionStatus = 'R' -- RollBack
		ELSE 
			SET		@ExecutionStatus = 'E' -- Execution Started

		INSERT INTO [ssis].[Execution]
				([ParentExecutionID]
				,[ExecutionGUID]
				,[SourceGUID]
				,[ParentSourceGUID]
				,[PackageID]
				,[ServerExecutionID]
				,[ExecutionStatus])
		VALUES	(ISNULL(@ParentExecutionID, -1)
				,REPLACE(REPLACE(@ExecutionGUID, '{', ''), '}', '')
				,REPLACE(REPLACE(@SourceGUID, '{', ''), '}', '')
				,ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '')
				,@PackageID
				,@ServerExecutionID
				,@ExecutionStatus);

		SELECT  @ExecutionID = SCOPE_IDENTITY();
	END
END

IF ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '') <> ''
BEGIN
	UPDATE	[ssis].[Execution]
	SET		[ParentSourceGUID] = REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', '')
	WHERE	[ExecutionID] = @ExecutionID
END

