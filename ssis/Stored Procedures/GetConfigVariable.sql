/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetConfigVariable]
    @SystemName			[varchar](100),
	@ObjectName			[varchar](500),
	@VariableName		[varchar](100),
	@VariableValue		[varchar](200),
	@ExecutionID		[bigint]
AS
SET NOCOUNT ON
--BEGIN TRY
	IF UPPER(ISNULL(@VariableValue, '')) IN ('', 'NULL') SET @VariableValue = NULL; 

	IF NOT EXISTS (
		SELECT	1 
		FROM	[ssis].[ConfigVariable]
		WHERE	[SystemName] = @SystemName
		AND		[ObjectName] = @ObjectName
		AND		[VariableName] = @VariableName)
	BEGIN
		INSERT INTO [ssis].[ConfigVariable]
				([SystemName]
				,[ObjectName]
				,[VariableName]
				,[VariableValue]
				,[ExecutionID]
				)
		VALUES	(@SystemName
				,@ObjectName
				,@VariableName
				,@VariableValue
				,@ExecutionID
				)
	END
	--ELSE
	--BEGIN
	--	UPDATE	[ssis].[ConfigVariable]
	--	SET		[RollbackValue] = [VariableValue]
	--			--,[RollbackExecutionID] = [ExecutionID]
	--	WHERE	[SystemName] = @SystemName
	--	AND		[ObjectName] = @ObjectName
	--	AND		[VariableName] = @VariableName
	--END

	SELECT	TOP 1 ISNULL([VariableValue], @VariableValue)
	FROM	[ssis].[ConfigVariable]
	WHERE	[SystemName] = @SystemName
	AND		[ObjectName] = @ObjectName
	AND		[VariableName] = @VariableName

--	RETURN(0);
--END TRY

--BEGIN CATCH
--    RETURN ERROR_NUMBER();
--END CATCH;
GO
