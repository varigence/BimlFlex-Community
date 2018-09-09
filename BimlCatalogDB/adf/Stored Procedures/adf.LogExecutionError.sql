/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[LogExecutionError](
	@ExecutionID		[BIGINT],
	@ActivityName		NVARCHAR(200) NULL,
	@ActivityOutput		NVARCHAR(MAX) NULL,
	@OutputMessage		NVARCHAR(MAX) NULL,
	@OutputError		NVARCHAR(MAX) NULL
)
AS 
-- TODO: check for and register non-existent run first, error condition has happened in the ADF fabric?
INSERT INTO [adf].[ExecutionError] (ExecutionID, ActivityName, ActivityOutput, OutputMessage, OutputError) 
	VALUES (@ExecutionID, @ActivityName, @ActivityOutput, @OutputMessage, @OutputError)
