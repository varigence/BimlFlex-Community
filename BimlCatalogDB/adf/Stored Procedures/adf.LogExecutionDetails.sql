/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[LogExecutionDetails](
	@ExecutionID			BIGINT,
	@ParentExecutionID		BIGINT = NULL,
	@DataFactory			NVARCHAR(65),
	@Pipeline				NVARCHAR(2000),
	@RunId        			NVARCHAR(100),
	@TriggerType			NVARCHAR(100) = NULL,
	@TriggerId				NVARCHAR(100) = NULL,
	@TriggerName			NVARCHAR(100) = NULL,
	@TriggerTime			NVARCHAR(100) = NULL,
	@TriggerScheduledTime	NVARCHAR(100) = NULL,
	@TriggerStartTime		NVARCHAR(100) = NULL,
	@TriggerWindowStartTime	NVARCHAR(100) = NULL,
	@TriggerWindowEndTime	NVARCHAR(100) = NULL,
	@ProjectName			VARCHAR(500)  = NULL
)
AS 

DECLARE	 @PipelineID			INT
		,@IsEnabled				BIT
		,@ExecutionStartTime	DATETIME
		,@ParentPipelineID		INT
		,@CurrentExecutionID	BIGINT
		,@LastExecutionID		BIGINT
		,@LastNextLoadStatus	VARCHAR(1)
		,@LastExecutionStatus	VARCHAR(1)
		,@PipelineRetryCount	INT
		,@ExecutionStatus		VARCHAR(1)
		,@NextLoadStatus		VARCHAR(1)
		,@BatchStartTime		DATETIME

SELECT @ExecutionStartTime = GETUTCDATE()

-- check if run is registered
IF NOT EXISTS (SELECT 1 from [adf].[Execution] WHERE ExecutionID = @ExecutionID)
BEGIN
	-- register non-existent run first, error condition has happened in the ADF fabric - possibly abort?
	INSERT INTO [adf].[Execution] (DataFactory, Pipeline, StartTime) VALUES ('Unknown', 'Unknown', @ExecutionStartTime)
	SELECT @ExecutionID = SCOPE_IDENTITY()
END


UPDATE [adf].[Execution]
SET
	DataFactory					= @DataFactory,
	Pipeline					= @Pipeline,
	RunId        				= @RunId,
	TriggerType					= @TriggerType,
	TriggerId					= @TriggerId,
	TriggerName					= @TriggerName,
	TriggerTime					= @TriggerTime,
	TriggerScheduledTime		= @TriggerScheduledTime,
	TriggerStartTime			= @TriggerStartTime,
	TriggerWindowStartTime		= @TriggerWindowStartTime,
	TriggerWindowEndTime		= @TriggerWindowEndTime
WHERE 
	ExecutionID = @ExecutionID


	-- check current running pipeline (defined as pipeline name in the current factory name)
	SELECT	 @PipelineID = PipelineID
			,@IsEnabled = [IsEnabled]
	FROM	[adf].[Pipeline]
	WHERE	[Pipeline] = @Pipeline
	AND		[DataFactory] = @DataFactory


	IF @PipelineID IS NULL
	BEGIN
		INSERT INTO [adf].[Pipeline] (DataFactory, Pipeline) VALUES (@DataFactory, @Pipeline)
		SELECT @PipelineID = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE	[adf].[Pipeline]
		SET		[ProjectName] = ISNULL(@ProjectName, 'Not Specified')
		WHERE	[PipelineID] = @PipelineID
	END

	-- Check if Pipeline is already executing
	SELECT	 @CurrentExecutionID = [ExecutionID]
	FROM	[adf].[Execution]
	WHERE	[ExecutionID] = 
		(
			SELECT	MAX([ExecutionID])
			FROM	[adf].[Execution]
			WHERE	[PipelineID] = @PipelineID
			AND		[ExecutionID] < @ExecutionID
			AND		[ExecutionStatus] = 'E'
		)

	-- Get previous execution status
	SELECT	 @LastNextLoadStatus = [NextLoadStatus]
			,@LastExecutionStatus = [ExecutionStatus]
			,@LastExecutionID = [ExecutionID]
	FROM	[adf].[Execution]
	WHERE	[ExecutionID] = 
		(
		-- select the last one that ran, as the execution start process has already created this run, get the one before
			SELECT	MAX([ExecutionID])
			FROM	[adf].[Execution]
			WHERE	[PipelineID] = @PipelineID
			AND		[ExecutionID] < @ExecutionID
		)

	-- If the pipeline is currently executing or disabled abort the process.
	IF @IsEnabled = 0
	BEGIN
		SELECT @ExecutionStatus = 'C' -- Disabled Skip Execution
		SELECT @NextLoadStatus = 'P'
	END
	ELSE IF @CurrentExecutionID IS NOT NULL -- Currently Executing
	BEGIN
		SELECT	@PipelineRetryCount = ISNULL([PipelineRetryCount], 0) + 1
		FROM	[adf].[Pipeline]
		WHERE	[PipelineID] = @PipelineID
		IF @PipelineRetryCount >= COALESCE((SELECT TOP 1 CONVERT(INT, [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'PipelineRetryLimit'), 0)
		BEGIN
			SET	@PipelineRetryCount = 0
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
					,[EndTime] = ISNULL(e.[EndTime], GETDATE())
			FROM	[adf].[Execution] e
			INNER JOIN [adf].[Pipeline] p 
				ON e.[PipelineID] = p.[PipelineID]
			INNER JOIN [adf].[Execution] ep
				ON CASE	WHEN e.[ParentExecutionID] = -1 THEN e.[ExecutionID] ELSE e.[ParentExecutionID] END = ep.[ExecutionID]
			INNER JOIN [adf].[Pipeline] pp 
				ON ep.[PipelineID] = pp.[PipelineID]
			WHERE	 e.[ExecutionStatus] = 'E'
			AND		(e.[ExecutionID] = ISNULL(@CurrentExecutionID, e.[ExecutionID]) OR ep.[ExecutionID] = ISNULL(@CurrentExecutionID, ep.[ExecutionID]))
		END
		UPDATE	[adf].[Pipeline] 
		SET		[PipelineRetryCount] = @PipelineRetryCount 
		WHERE	[PipelineID] = @PipelineID
	END
	ELSE IF ISNULL(@LastNextLoadStatus, 'P') = 'R' -- Failed - Rollback
	BEGIN
		SELECT @ExecutionStatus = 'R' -- RollBack
		SELECT @NextLoadStatus = 'C'
	END
	ELSE IF ISNULL(@LastNextLoadStatus, 'P') = 'C' -- Skip next run. Pipeline completed, but not set for next run by batch.
	BEGIN
		SELECT @ExecutionStatus = 'C' -- Skip Execution
		SELECT @NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
	END
	ELSE 
	BEGIN
		SELECT	@ExecutionStatus = 'E' -- Execution Started
		SELECT	@NextLoadStatus = 'C' -- Skip Next Run. Gets reset based on completion or failure.
	END


	IF ISNULL(@ParentExecutionID, -99) <> -99 -- -1 is used as default placeholder in sub pipeline due to limitations with null in ADF pipeline parameters
	BEGIN
		SELECT	 @ParentPipelineID = MAX([PipelineID])
				,@BatchStartTime = MAX([BatchStartTime])
		FROM	[adf].[Execution] 
		WHERE	[ExecutionID] = @ParentExecutionID
	END

SELECT 
    ISNULL(@LastExecutionID, @ExecutionID) AS LastExecutionID,
	ISNULL(@ExecutionStatus, 'C') AS ExecutionStatus,
	ISNULL(@NextLoadStatus, 'C') AS NextLoadStatus

