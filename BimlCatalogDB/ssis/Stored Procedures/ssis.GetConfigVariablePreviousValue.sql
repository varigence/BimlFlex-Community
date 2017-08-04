/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetConfigVariablePreviousValue]
    @SystemName			[VARCHAR](100),
	@ObjectName			[VARCHAR](500),
	@VariableName		[VARCHAR](100)
AS
SET NOCOUNT ON

	SELECT	TOP 1 [PreviousValue]
	FROM	[ssis].[ConfigVariable]
	WHERE	[SystemName] = @SystemName
	AND		[ObjectName] = @ObjectName
	AND		[VariableName] = @VariableName

GO