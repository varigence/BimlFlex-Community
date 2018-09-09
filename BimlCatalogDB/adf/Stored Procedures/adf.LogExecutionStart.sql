/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[LogExecutionStart](
	@ParentExecutionID	BIGINT = NULL
)
AS 

DECLARE @ExecutionStartTime [DATETIME], 
		@ExecutionID		[BIGINT]

SELECT @ExecutionStartTime = GETUTCDATE()
INSERT INTO [adf].[Execution] (DataFactory, Pipeline, StartTime, ParentExecutionID) VALUES ('Unknown', 'Unknown', @ExecutionStartTime, @ParentExecutionID)
SELECT @ExecutionID = SCOPE_IDENTITY()

SELECT 
	@ExecutionStartTime		AS ExecutionStartTime, 
	@ExecutionID			AS ExecutionID