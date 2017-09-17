/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[SetEnablePackage]
	@ProjectName			[varchar](500),
	@PackageName			[varchar](500)
----WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int

	DECLARE	@PackageID		INT

	SELECT	 @PackageID = [PackageID]
	FROM	[ssis].[Package]
	WHERE	[PackageName] = @PackageName
	AND		[ProjectName] = @ProjectName

	IF @PackageID IS NULL
	BEGIN
		SELECT	 @PackageID = [PackageID]
		FROM	[ssis].[Package]
		WHERE	[PackageName] = @PackageName
	END

	BEGIN TRANSACTION
		UPDATE	e
		SET		[NextLoadStatus] = 'P'
		FROM	[ssis].[Execution] e
		WHERE	[ExecutionID] = 
		(
			SELECT	MAX([ExecutionID])
			FROM	[ssis].[Execution]
			WHERE	[PackageID] = @PackageID
		)
			AND	[NextLoadStatus] NOT IN ('P', 'R')

		UPDATE	p
		SET		[IsEnabled] = 1
		FROM	[ssis].[Package] p 
		WHERE	p.[PackageID] = @PackageID
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