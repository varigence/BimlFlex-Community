/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogExecutionError]
	@ExecutionID		BIGINT,
	@IsBatch			BIT,
	@ErrorCode			INT,
	@ErrorDescription	NVARCHAR(MAX)
----WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int

	DECLARE	@SourceGUID				[nvarchar](40),
			@PackageID				[int],
			@ServerExecutionID		[bigint]

	BEGIN TRANSACTION
		IF @IsBatch = 1
		BEGIN
			UPDATE	[ssis].[Execution]
			SET		[NextLoadStatus] = 'C'
			WHERE	[ParentExecutionID] = @ExecutionID
			AND		[ExecutionStatus] = 'S'

			--UPDATE	cv
			--SET		[VariableValue] = ISNULL([PreviousValue], [VariableValue])
			--FROM	[ssis].[Execution] e
			--INNER JOIN [ssis].[ConfigVariable] cv
			--	ON	e.[ExecutionID] = cv.[ExecutionID]
			--WHERE	e.[ParentExecutionID] = @ExecutionID
		END
	
		UPDATE	[ssis].[Execution]
		SET		 [ExecutionStatus] = 'F' -- Failed
				,[NextLoadStatus] = 'R'
				,[EndTime] = GETDATE()
				,@PackageID = [PackageID]
		WHERE	[ExecutionID] = @ExecutionID

		INSERT INTO [ssis].[ExecutionError]
				([PackageID]
				,[ExecutionID]
				,[ErrorCode]
				,[ErrorDescription])
		VALUES	(@PackageID
				,@ExecutionID
				,@ErrorCode
				,@ErrorDescription)

		SELECT	 @ServerExecutionID = [ServerExecutionID]
				,@SourceGUID = [SourceGUID]
				,@PackageID = [PackageID]
		FROM	[ssis].[Execution]
		WHERE	[ExecutionID] = @ExecutionID

		EXEC [ssis].[LogTaskExecution] @SourceGUID, @PackageID, @ExecutionID, @ServerExecutionID

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

GO