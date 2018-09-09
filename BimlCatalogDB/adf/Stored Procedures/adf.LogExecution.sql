
/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[LogExecution](
	@DataFactory				NVARCHAR(65),
	@Pipeline					NVARCHAR(2000),
	@RunId        				NVARCHAR(100),
	@TriggerType				NVARCHAR(100),
	@TriggerId					NVARCHAR(100),
	@TriggerName				NVARCHAR(100),
	@TriggerTime				NVARCHAR(100),
	@TriggerScheduledTime		NVARCHAR(100),
	@TriggerStartTime			NVARCHAR(100),
	@TriggerWindowStartTime		NVARCHAR(100),
	@TriggerWindowEndTime		NVARCHAR(100),
	@ExecutionID				BIGINT = NULL OUTPUT,
	@ExecutionStatus			VARCHAR(1) = NULL OUTPUT,
	@NextLoadStatus				VARCHAR(1) = NULL OUTPUT,
	@LastExecutionID			BIGINT = NULL OUTPUT,
	@PipelineStartTime			DATETIME = NULL OUTPUT
)
AS 

DECLARE	 @PipelineID INT

IF @ExecutionID IS NULL
BEGIN
	--SELECT	 @PipelineID = [PipelineID]
	--		,@IsEnabled = [IsEnabled]
	--FROM	[adf].[Pipeline]
	--WHERE	[PipelineName] = @PipelineName
	--AND		[ProjectName] = ISNULL(@ProjectName, 'Not Specified')

	--IF @PipelineID IS NULL
	--BEGIN
	--	SELECT	 @PipelineID = [PipelineID]
	--			,@IsEnabled = [IsEnabled]
	--	FROM	[adf].[Pipeline]
	--	WHERE	[PipelineName] = @PipelineName

	--	IF @PipelineID IS NULL
	--	BEGIN
			INSERT INTO [adf].[Pipeline] (DataFactory, Pipeline) VALUES (@DataFactory, @Pipeline)
			SELECT @PipelineID = SCOPE_IDENTITY();
	--	END
	--	ELSE
	--	BEGIN
	--		UPDATE	[adf].[Pipeline]
	--		SET		[ProjectName] = ISNULL(@ProjectName, 'Not Specified')
	--		WHERE	[PipelineID] = @PipelineID
	--	END
	--END

	-- Check if Package is already executing
--	SELECT	 @CurrentExecutionID = [ExecutionID]
--	FROM	[adf].[Execution]
--	WHERE	[ExecutionID] = 
--		(
--			SELECT	MAX([ExecutionID])
--			FROM	[adf].[Execution]
--			WHERE	[PipelineID] = @PipelineID
--			AND		[ExecutionStatus] = 'E'
--		)

--	-- Get previous execution status
--	SELECT	 @LastNextLoadStatus = [NextLoadStatus]
--			,@LastExecutionStatus = [ExecutionStatus]
--			,@LastExecutionID = [ExecutionID]
--	FROM	[adf].[Execution]
--	WHERE	[ExecutionID] = 
--		(
--			SELECT	MAX([ExecutionID])
--			FROM	[adf].[Execution]
--			WHERE	[PipelineID] = @PipelineID
--		)

--	-- If the package is currently executing or disabled abort the process.
--	IF @IsEnabled = 0
--	BEGIN
--		SELECT @ExecutionStatus = 'C' -- Disabled Skip Execution
--		SELECT @NextLoadStatus = 'P'
--	END
--	ELSE IF @CurrentExecutionID IS NOT NULL -- Currently Executing
--	BEGIN
--		SELECT	@PipelineRetryCount = ISNULL([PipelineRetryCount], 0) + 1
--		FROM	[adf].[Pipeline]
--		WHERE	[PipelineID] = @PipelineID
--		IF @PipelineRetryCount >= COALESCE((SELECT TOP 1 CONVERT(INT, [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'PackageRetryLimit'), 0)
--		BEGIN
--			SET	@PipelineRetryCount = 0
--			SELECT	@ExecutionStatus = 'E' -- Execution Started
--			SELECT	@NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
--		END
--		ELSE
--		BEGIN
--			SELECT @ExecutionStatus = 'A' -- Abort this instance
--			SELECT @NextLoadStatus = 'P'

--			UPDATE	e
--			SET		[ExecutionStatus] = 'A'
--					,[NextLoadStatus] = 'C'
--					,[EndTime] = ISNULL(e.[EndTime], GETDATE())
--			FROM	[adf].[Execution] e
--			INNER JOIN [adf].[Pipeline] p 
--				ON e.[PipelineID] = p.[PipelineID]
--			INNER JOIN [adf].[Execution] ep
--				ON CASE	WHEN e.[ParentExecutionID] = -1 THEN e.[ExecutionID] ELSE e.[ParentExecutionID] END = ep.[ExecutionID]
--			INNER JOIN [adf].[Pipeline] pp 
--				ON ep.[PipelineID] = pp.[PipelineID]
--			WHERE	 e.[ExecutionStatus] = 'E'
--			AND		(e.[ExecutionID] = ISNULL(@CurrentExecutionID, e.[ExecutionID]) OR ep.[ExecutionID] = ISNULL(@CurrentExecutionID, ep.[ExecutionID]))
--		END
--		UPDATE	[adf].[Pipeline] 
--		SET		[PipelineRetryCount] = @PipelineRetryCount 
--		WHERE	[PipelineID] = @PipelineID
--	END
--	ELSE IF ISNULL(@LastNextLoadStatus, 'P') = 'R' -- Failed - Rollback
--	BEGIN
--		SELECT @ExecutionStatus = 'R' -- RollBack
--		SELECT @NextLoadStatus = 'C'
--	END
--	ELSE IF ISNULL(@LastNextLoadStatus, 'P') = 'C' -- Skip next run. Package completed, but not set for next run by batch.
--	BEGIN
--		SELECT @ExecutionStatus = 'C' -- Skip Execution
--		SELECT @NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
--	END
--	ELSE 
--	BEGIN
--		SELECT	@ExecutionStatus = 'E' -- Execution Started
--		SELECT	@NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
--	END

	
--	IF ISNULL(@ParentExecutionID, -1) <> -1
--	BEGIN
--		SELECT	 @ParentPackageID = MAX([PipelineID])
--				,@BatchStartTime = MAX([BatchStartTime])
--		FROM	[adf].[Execution] 
--		WHERE	[ExecutionID] = @ParentExecutionID
--	END

	SET	@PipelineStartTime = ISNULL(@PipelineStartTime, GETUTCDATE())

	INSERT INTO [adf].[Execution]
           ([DataFactory]
           ,[Pipeline]
           ,[RunId]
           ,[TriggerType]
           ,[TriggerId]
           ,[TriggerName]
           ,[TriggerTime]
           ,[TriggerScheduledTime]
           ,[TriggerStartTime]
           ,[TriggerWindowStartTime]
           ,[TriggerWindowEndTime]
           ,[ExecutionStatus]
           ,[NextLoadStatus]
           ,[StartTime]
           )
     VALUES
           (@DataFactory
           ,@Pipeline
           ,@RunId
           ,@TriggerType
           ,@TriggerId
           ,@TriggerName
           ,@TriggerTime
           ,@TriggerScheduledTime
           ,@TriggerStartTime
           ,@TriggerWindowStartTime
           ,@TriggerWindowEndTime
           ,@ExecutionStatus
           ,@NextLoadStatus
           ,@PipelineStartTime

		   )

--	SELECT  @ExecutionID = SCOPE_IDENTITY();

--	IF ISNULL(@ParentExecutionID, -1) <> -1
--	BEGIN
--		SELECT	@ParentPackageID = MAX([PipelineID])
--		FROM	[adf].[Execution] 
--		WHERE	[ExecutionID] = @ParentExecutionID

--		UPDATE	[adf].[Pipeline]
--		SET		[ParentPipelineID] = @ParentPackageID
--		WHERE	[PipelineID] = @PipelineID
--	END
--END

--IF ISNULL(REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', ''), '') <> ''
--BEGIN
--	UPDATE	[adf].[Execution]
--	SET		[ParentSourceGUID] = REPLACE(REPLACE(@ParentSourceGUID, '{', ''), '}', '')
--	WHERE	[ExecutionID] = @ExecutionID
--END

--SELECT	@LastExecutionID = ISNULL(@LastExecutionID, @ExecutionID)
--SELECT	@ExecutionStatus = ISNULL(@ExecutionStatus, 'C')
--SELECT	@NextLoadStatus = ISNULL(@NextLoadStatus, 'C')
--SELECT	@BatchStartTime = ISNULL(@BatchStartTime, GETDATE())

SELECT 
    @PipelineStartTime AS PipelineStartTime, 
    @ExecutionID AS ExecutionID, 
	/*@ExecutionStatus*/ 'E' AS ExecutionStatus,
	/*@NextLoadStatus*/ 'C' AS NextLoadStatus


	END