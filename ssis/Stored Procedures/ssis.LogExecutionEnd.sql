/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogExecutionEnd]
	@ExecutionID		BIGINT,
	@IsBatch			BIT
----WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int

	DECLARE	@SourceGUID				[nvarchar](40),
			@PackageID				[int],
			@ServerExecutionID		[bigint]

	BEGIN TRANSACTION
		UPDATE	[ssis].[Execution]
		SET		 [ExecutionStatus] = 'S' -- Success
				,[NextLoadStatus] = 'P'
				,[EndTime] = GETDATE()
		WHERE	[ExecutionID] = @ExecutionID

		IF @IsBatch = 1
		BEGIN
			UPDATE	[ssis].[Execution]
			SET		[NextLoadStatus] = 'P'
			WHERE	[ParentExecutionID] = @ExecutionID
		END

		SELECT	 @ServerExecutionID = [ServerExecutionID]
				,@SourceGUID = [SourceGUID]
				,@PackageID = [PackageID]
		FROM	[ssis].[Execution]
		WHERE	[ExecutionID] = @ExecutionID

		IF (ISNULL((SELECT TOP 1 CONVERT(CHAR(1), [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'LogTaskExecution'), 'N') = 'Y')
		BEGIN
			EXEC [ssis].[LogTaskExecution] @SourceGUID, @PackageID, @ExecutionID, @ServerExecutionID
		END

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