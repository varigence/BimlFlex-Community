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
	@ExecutionStatus		[varchar](1)	= NULL OUTPUT,
	@NextLoadStatus			[varchar](1)	= NULL OUTPUT,
	@LastExecutionID		[bigint]        = NULL OUTPUT,
	@BatchStartTime			[datetime]		= NULL OUTPUT,
	@ProjectName			[varchar](500)  = NULL
)
AS 

DECLARE	 @PackageID				INT
		,@ParentPackageID		INT
		,@CurrentExecutionID	BIGINT
		,@LastNextLoadStatus	VARCHAR(1)
		,@LastExecutionStatus	VARCHAR(1)
		,@IsEnabled				BIT
		,@PackageRetryCount		INT
		,@ExecutionStartTime	DATETIME


SELECT @ExecutionStartTime = CASE WHEN ISNULL((SELECT TOP 1 [ConfigurationValue] FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'UseGETUTCDATE'), 'N') = 'Y' THEN GETUTCDATE() ELSE GETDATE() END

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
	AND		[ProjectName] = ISNULL(@ProjectName, 'Not Specified')

	IF @PackageID IS NULL
	BEGIN
		SELECT	 @PackageID = [PackageID]
				,@IsEnabled = [IsEnabled]
		FROM	[ssis].[Package]
		WHERE	[PackageName] = @PackageName

		IF @PackageID IS NULL
		BEGIN
			INSERT INTO [ssis].[Package] ([ProjectName], [PackageName], [IsBatch]) VALUES (ISNULL(@ProjectName, 'Not Specified'), @PackageName, @IsBatch)
			SELECT @PackageID = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
			UPDATE	[ssis].[Package]
			SET		[ProjectName] = ISNULL(@ProjectName, 'Not Specified')
			WHERE	[PackageID] = @PackageID
		END
	END

	-- Check if Package is already executing
	SELECT	 @CurrentExecutionID = [ExecutionID]
	FROM	[ssis].[Execution]
	WHERE	[ExecutionID] = 
		(
			SELECT	MAX([ExecutionID])
			FROM	[ssis].[Execution]
			WHERE	[PackageID] = @PackageID
			AND		[ExecutionStatus] = 'E'
		)

	-- Get previous execution status
	SELECT	 @LastNextLoadStatus = [NextLoadStatus]
			,@LastExecutionStatus = [ExecutionStatus]
	FROM	[ssis].[Execution]
	WHERE	[ExecutionID] = 
		(
			SELECT	MAX([ExecutionID])
			FROM	[ssis].[Execution]
			WHERE	[PackageID] = @PackageID
		)

	-- Get Last Succesful ExecutionID
	SELECT	@LastExecutionID = [ExecutionID]
	FROM	[ssis].[Execution]
	WHERE	[ExecutionID] = 
		(
			SELECT	MAX([ExecutionID])
			FROM	[ssis].[Execution]
			WHERE	[PackageID] = @PackageID
			AND		[ExecutionStatus] = 'S'
		)

	-- If the package is currently executing or disabled abort the process.
	IF @IsEnabled = 0
	BEGIN
		SELECT @ExecutionStatus = 'C' -- Disabled Skip Execution
		SELECT @NextLoadStatus = 'P'
	END
	ELSE IF @CurrentExecutionID IS NOT NULL -- Currently Executing
	BEGIN
		SELECT	@PackageRetryCount = ISNULL([PackageRetryCount], 0) + 1
		FROM	[ssis].[Package]
		WHERE	[PackageID] = @PackageID
		IF @PackageRetryCount >= (SELECT TOP 1 CONVERT(INT, [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'PackageRetryLimit')
		BEGIN
			SET	@PackageRetryCount = 0
			SELECT	@ExecutionStatus = 'E' -- Execution Started
			SELECT	@NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
		END
		ELSE
		BEGIN
			SELECT @ExecutionStatus = 'A' -- Abort this instance
			SELECT @NextLoadStatus = 'P'

			UPDATE	e
			SET		[ExecutionStatus] = 'A'
					,[NextLoadStatus] = 'C'
					,[EndTime] = ISNULL(e.[EndTime], @ExecutionStartTime)
			FROM	[ssis].[Execution] e
			INNER JOIN [ssis].[Package] p 
				ON e.[PackageID] = p.[PackageID]
			INNER JOIN [ssis].[Execution] ep
				ON CASE	WHEN e.[ParentExecutionID] = -1 THEN e.[ExecutionID] ELSE e.[ParentExecutionID] END = ep.[ExecutionID]
			INNER JOIN [ssis].[Package] pp 
				ON ep.[PackageID] = pp.[PackageID]
			WHERE	 e.[ExecutionStatus] = 'E'
			AND		(e.[ExecutionID] = ISNULL(@CurrentExecutionID, e.[ExecutionID]) OR ep.[ExecutionID] = ISNULL(@CurrentExecutionID, ep.[ExecutionID]))
		END
		UPDATE	[ssis].[Package] 
		SET		[PackageRetryCount] = @PackageRetryCount 
		WHERE	[PackageID] = @PackageID
	END
	ELSE IF ISNULL(@LastNextLoadStatus, 'P') = 'R' -- Failed - Rollback
	BEGIN
		SELECT @ExecutionStatus = 'R' -- RollBack
		SELECT @NextLoadStatus = 'C'
	END
	ELSE IF ISNULL(@LastNextLoadStatus, 'P') = 'C' -- Skip next run. Package completed, but not set for next run by batch.
	BEGIN
		SELECT @ExecutionStatus = 'C' -- Skip Execution
		SELECT @NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
	END
	ELSE 
	BEGIN
		SELECT	@ExecutionStatus = 'E' -- Execution Started
		SELECT	@NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
	END

	
	IF ISNULL(@ParentExecutionID, -1) <> -1
	BEGIN
		SELECT	 @ParentPackageID = MAX([PackageID])
				,@BatchStartTime = MAX([BatchStartTime])
		FROM	[ssis].[Execution] 
		WHERE	[ExecutionID] = @ParentExecutionID
	END

	SET	@BatchStartTime = ISNULL(@BatchStartTime, @ExecutionStartTime)

	INSERT INTO [ssis].[Execution]
			([ParentExecutionID]
			,[ExecutionGUID]
			,[SourceGUID]
			,[ParentSourceGUID]
			,[PackageID]
			,[ServerExecutionID]
			,[ExecutionStatus]
			,[NextLoadStatus]
			,[StartTime]
			,[BatchStartTime])
	VALUES	(ISNULL(@ParentExecutionID, -1)
			,REPLACE(REPLACE(@ExecutionGUID, '{', ''), '}', '')
			,REPLACE(REPLACE(@SourceGUID, '{', ''), '}', '')
			,ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '')
			,@PackageID
			,@ServerExecutionID
			,@ExecutionStatus
			,@NextLoadStatus
			,CASE WHEN ISNULL(@ParentExecutionID, -1) = -1 THEN @BatchStartTime ELSE @ExecutionStartTime END
			,@BatchStartTime);

	SELECT  @ExecutionID = SCOPE_IDENTITY();

	IF ISNULL(@ParentExecutionID, -1) <> -1
	BEGIN
		SELECT	@ParentPackageID = MAX([PackageID])
		FROM	[ssis].[Execution] 
		WHERE	[ExecutionID] = @ParentExecutionID

		UPDATE	[ssis].[Package]
		SET		[ParentPackageID] = @ParentPackageID
		WHERE	[PackageID] = @PackageID
	END
END

IF ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '') <> ''
BEGIN
	UPDATE	[ssis].[Execution]
	SET		[ParentSourceGUID] = REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', '')
	WHERE	[ExecutionID] = @ExecutionID
END

SELECT	@LastExecutionID = ISNULL(@LastExecutionID, @ExecutionID)
SELECT	@ExecutionStatus = ISNULL(@ExecutionStatus, 'C')
SELECT	@NextLoadStatus = ISNULL(@NextLoadStatus, 'C')
SELECT	@BatchStartTime = ISNULL(@BatchStartTime, @ExecutionStartTime)

/*


UPDATE	pe
SET		[ExecutionStatus] = 'A'
		,[NextLoadStatus] = 'P'
FROM	[ssis].[Execution] pe
INNER JOIN 
(
SELECT	MAX([ExecutionID]) AS [ExecutionID]
FROM	[ssis].[Execution] e
INNER JOIN [ssis].[Package] p
	ON	e.[PackageID] = p.[PackageID]
WHERE	p.[PackageName] = 'SB_EOD_Batch'
) e
	ON	pe.[ExecutionID]  = e.[ExecutionID]
	OR	pe.[ParentExecutionID] = e.[ExecutionID]

SELECT	pe.*

UPDATE	pe
SET		[ExecutionStatus] = 'A'
		,[NextLoadStatus] = 'P'
FROM	[ssis].[Execution] pe
INNER JOIN 
(

SELECT	e.[ExecutionID]
FROM	[ssis].[Execution] e
INNER JOIN [ssis].[Package] p
	ON	e.[PackageID] = p.[PackageID]
WHERE	[ExecutionStatus] = 'E' 
) e
	ON	pe.[ExecutionID]  = e.[ExecutionID]
	OR	pe.[ParentExecutionID] = e.[ExecutionID]
	*/

GO