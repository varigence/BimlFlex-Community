﻿/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[SetConfigVariable]
    @SystemName			[varchar](100),
	@ObjectName			[varchar](500),
	@VariableName		[varchar](100),
	@VariableValue		[varchar](200)
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PreviousValue	VARCHAR(200)

	IF UPPER(ISNULL(@VariableValue, '')) IN ('', 'NULL', '0', '1900-01-01') SET @VariableValue = NULL; 

	SELECT	@PreviousValue = [VariableValue]
	FROM	[ssis].[ConfigVariable]
	WHERE	[SystemName] = @SystemName
	AND		[ObjectName] = @ObjectName
	AND		[VariableName] = @VariableName	
	
	-- Write test for variable casting
	--IF TRY_PARSE(@PreviousValue AS DATETIME2, )
	IF (@PreviousValue > @VariableValue)
	BEGIN
		UPDATE	[ssis].[ConfigVariable]
		SET		 [VariableValue] = ISNULL(@VariableValue, [VariableValue])
				,[PreviousValue] = @PreviousValue
		WHERE	[SystemName] = @SystemName
		AND		[ObjectName] = @ObjectName
		AND		[VariableName] = @VariableName
	END

	RETURN(0);
END TRY

BEGIN CATCH
    RETURN ERROR_NUMBER();
END CATCH;
GO
