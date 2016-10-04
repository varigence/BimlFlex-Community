/*
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
	@VariableValue		[varchar](200),
	@ExecutionID		[bigint] = NULL
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PreviousValue			VARCHAR(200)

	SELECT	 @PreviousValue = [VariableValue]
	FROM	[ssis].[ConfigVariable]
	WHERE	[SystemName] = @SystemName
	AND		[ObjectName] = @ObjectName
	AND		[VariableName] = @VariableName	

	-- Handle dates retaining largest in cases where incremental loads returned no records
	IF (ISDATE(@PreviousValue) = 1 OR ISDATE(@VariableValue) = 1)
	BEGIN
		DECLARE	@PreviousDate	DATETIME2(7)
		IF (ISDATE(@PreviousValue) = 1) SET @PreviousDate = CAST(@PreviousValue AS DATETIME2(7))
		SET	@PreviousDate = ISNULL(@PreviousDate, '1900-01-01')
		DECLARE	@CurrentDate	DATETIME2(7)
		IF (ISDATE(@VariableValue) = 1) SET @CurrentDate = CAST(@VariableValue AS DATETIME2(7))
		SET	@CurrentDate = ISNULL(@CurrentDate, '1900-01-01')
		IF (@CurrentDate < @PreviousDate) SET @VariableValue = @PreviousValue
	END
	-- Handle numerics retaining largest in cases where incremental loads returned no records
	ELSE IF (ISNUMERIC(@PreviousValue) = 1 OR ISNUMERIC(@VariableValue) = 1)
	BEGIN
		DECLARE	@PreviousNumber	DECIMAL(38,8)
		IF (ISNUMERIC(@PreviousValue) = 1) SET @PreviousNumber = CAST(@PreviousValue AS DECIMAL(38,8))
		SET	@PreviousNumber = ISNULL(@PreviousNumber, 0)
		DECLARE	@CurrentNumber	DECIMAL(38,8)
		IF (ISNUMERIC(@VariableValue) = 1) SET @CurrentNumber = CAST(@VariableValue AS DECIMAL(38,8))
		SET	@CurrentNumber = ISNULL(@CurrentNumber, 0)
		IF (@CurrentNumber < @PreviousNumber) SET @VariableValue = @PreviousValue
	END

	IF UPPER(ISNULL(@VariableValue, '')) IN ('', 'NULL', '0', '1900-01-01') 
		AND UPPER(ISNULL(@PreviousValue, '')) NOT IN ('', 'NULL', '0', '1900-01-01') 
		SET @VariableValue = @PreviousValue; 
	
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
				,[ExecutionID])
		VALUES	(@SystemName
				,@ObjectName
				,@VariableName
				,@VariableValue
				,@ExecutionID)
	END
	ELSE
	BEGIN
		UPDATE	[ssis].[ConfigVariable]
		SET		 [VariableValue] = ISNULL(@VariableValue, [VariableValue])
				,[ExecutionID] = @ExecutionID
				,[PreviousValue] = @PreviousValue
		WHERE	[SystemName] = @SystemName
		AND		[ObjectName] = @ObjectName
		AND		[VariableName] = @VariableName
	END

	--RETURN(0);
END TRY

BEGIN CATCH
    --RETURN ERROR_NUMBER();
END CATCH;
GO
