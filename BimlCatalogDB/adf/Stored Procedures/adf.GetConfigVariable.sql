
/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[GetConfigVariable]
    @SystemName			[VARCHAR](100),
	@ObjectName			[VARCHAR](500),
	@VariableName		[VARCHAR](100),
	@VariableValue		[VARCHAR](200),
	@ExecutionID		[BIGINT] = NULL
AS
SET NOCOUNT ON
--BEGIN TRY
	IF UPPER(ISNULL(@VariableValue, '')) IN ('', 'NULL') SET @VariableValue = NULL; 

	IF NOT EXISTS (
		SELECT	1 
		FROM	[adf].[ConfigVariable]
		WHERE	[SystemName] = @SystemName
		AND		[ObjectName] = @ObjectName
		AND		[VariableName] = @VariableName)
	BEGIN
		INSERT INTO [adf].[ConfigVariable]
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

		IF (ISNULL((SELECT TOP 1 CONVERT(CHAR(1), [ConfigurationValue]) FROM [admin].[Configurations] WHERE [ConfigurationCode] = 'BimlFlex' AND [ConfigurationKey] = 'AuditConfigurationValue'), 'N') = 'Y')
		BEGIN
			INSERT INTO [adf].[AuditConfigVariable]
					([ConfigVariableID]
					,[SystemName]
					,[ObjectName]
					,[VariableName]
					,[VariableValue]
					,[ExecutionID]
					,[PreviousValue])
			SELECT	 [ConfigVariableID]
					,[SystemName]
					,[ObjectName]
					,[VariableName]
					,[VariableValue]
					,[ExecutionID]
					,[PreviousValue]
			FROM	[adf].[ConfigVariable]
			WHERE	[SystemName] = @SystemName
			AND		[ObjectName] = @ObjectName
			AND		[VariableName] = @VariableName
		END
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

	SELECT	TOP 1 ISNULL([VariableValue], @VariableValue) AS VariableValue
	FROM	[adf].[ConfigVariable]
	WHERE	[SystemName] = @SystemName
	AND		[ObjectName] = @ObjectName
	AND		[VariableName] = @VariableName

--	RETURN(0);
--END TRY

--BEGIN CATCH
--    RETURN ERROR_NUMBER();
--END CATCH;