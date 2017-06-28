/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[ResetExecutionStatus]
	@ExecutionID		BIGINT			= NULL
	,@PackageID			INT				= NULL
	,@PackageName		VARCHAR(255)	= NULL
----WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int

	BEGIN TRANSACTION
		UPDATE	e
		SET		[ExecutionStatus] = 'A'
				,[NextLoadStatus] = 'C'
				,[EndTime] = ISNULL(e.[EndTime], GETDATE())
		FROM	[ssis].[Execution] e
		INNER JOIN [ssis].[Package] p 
			ON e.[PackageID] = p.[PackageID]
		INNER JOIN [ssis].[Execution] ep
			ON CASE	WHEN e.[ParentExecutionID] = -1 THEN e.[ExecutionID] ELSE e.[ParentExecutionID] END = ep.[ExecutionID]
		INNER JOIN [ssis].[Package] pp 
			ON ep.[PackageID] = pp.[PackageID]
		WHERE	 e.[ExecutionStatus] = 'E'
		AND		(e.[ExecutionID] = ISNULL(@ExecutionID, e.[ExecutionID]) OR ep.[ExecutionID] = ISNULL(@ExecutionID, ep.[ExecutionID]))
		AND		(e.[PackageID] = ISNULL(@PackageID, e.[PackageID]) OR ep.[PackageID] = ISNULL(@PackageID, ep.[PackageID]))
		AND		(p.[PackageName] = ISNULL(@PackageName, p.[PackageName]) OR pp.[PackageName] = ISNULL(@PackageName, pp.[PackageName]))
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