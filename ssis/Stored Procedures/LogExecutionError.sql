/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[LogExecutionError]
	@ExecutionID		BIGINT,
	@ErrorCode			INT,
	@ErrorDescription	NVARCHAR(MAX)
WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int

	DECLARE	@PackageID		INT

	BEGIN TRANSACTION
		UPDATE	[ssis].[Execution]
		SET		 [ExecutionStatus] = 'F' -- Failed
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