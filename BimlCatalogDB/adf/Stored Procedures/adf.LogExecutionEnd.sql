/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[LogExecutionEnd]
	@ExecutionID		BIGINT
--	@IsBatch			BIT
----WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int

	--DECLARE	@SourceGUID				[nvarchar](40),
	--		@PipelineID				[int],
	--		@ServerExecutionID		[bigint]

	BEGIN TRANSACTION
		UPDATE	[adf].[Execution]
		SET		 [ExecutionStatus] = 'S' -- Success
				,[NextLoadStatus] = 'P'
				,[EndTime] = GETDATE()
		WHERE	[ExecutionID] = @ExecutionID

--		IF @IsBatch <> 1
		--BEGIN
		--	-- Update multi thread failure checking if Batch failed.
		--	UPDATE	fe
		--	SET		[NextLoadStatus] = 'C'
		--	FROM	[adf].[Execution] e
		--	INNER JOIN
		--	(
		--		SELECT	[ParentExecutionID]
		--		FROM	[adf].[Execution]
		--		WHERE	[ExecutionID] = @ExecutionID
		--	) pe
		--		ON	e.[ExecutionID] = pe.[ParentExecutionID]
		--		AND	pe.[ParentExecutionID] <> -1
		--		AND	e.[ExecutionStatus] = 'F'
		--	INNER JOIN [adf].[Execution] fe
		--		ON	e.[ExecutionID] = fe.[ParentExecutionID]
		--		AND	fe.[ExecutionID] = @ExecutionID
		--		AND	fe.[ExecutionStatus] = 'S'
		--END

		--IF @IsBatch = 1
		--BEGIN
		--	UPDATE	[adf].[Execution]
		--	SET		[NextLoadStatus] = 'P'
		--	WHERE	[ParentExecutionID] = @ExecutionID
		--END

		--SELECT	 @ServerExecutionID = [ServerExecutionID]
		--		,@SourceGUID = [SourceGUID]
		--		,@PipelineID = [PipelineID]
		--FROM	[adf].[Execution]
		--WHERE	[ExecutionID] = @ExecutionID

		--IF (ISNULL((SELECT TOP 1 CONVERT(CHAR(1), [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'LogTaskExecution'), 'N') = 'Y')
		--BEGIN
		--	EXEC [adf].[LogTaskExecution] @SourceGUID, @PipelineID, @ExecutionID, @ServerExecutionID
		--END

	COMMIT
END TRY

BEGIN CATCH
	-- What an error in my metadata!!
	IF @@TRANCOUNT > 0
		ROLLBACK

	-- Raise an error
	SELECT	@ErrMsg = ERROR_MESSAGE(),
			@ErrSeverity = ERROR_SEVERITY()

	RAISERROR(@ErrMsg, @ErrSeverity, 1)
END CATCH