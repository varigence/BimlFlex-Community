/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[SetDisablePackage]
	@ProjectName			[varchar](500),
	@PackageName			[varchar](500),
	@DisableOrSkip			[char](1)		= 'S'
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
		IF (@DisableOrSkip = 'S')
		BEGIN
			UPDATE	e
			SET		[NextLoadStatus] = 'C'
			FROM	[ssis].[Execution] e
			WHERE	[ExecutionID] = 
			(
				SELECT	MAX([ExecutionID])
				FROM	[ssis].[Execution]
				WHERE	[PackageID] = @PackageID
			)
		END
		IF (@DisableOrSkip = 'D')
		BEGIN
			UPDATE	p
			SET		[IsEnabled] = 0
			FROM	[ssis].[Package] p 
			WHERE	p.[PackageID] = @PackageID
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