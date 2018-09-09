/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [adf].[ExecutionError] (
    [ExecutionErrorID]		BIGINT IDENTITY (1, 1) NOT NULL,
    [ExecutionID]			BIGINT NOT NULL,
    [ActivityName]			[NVARCHAR](200) NULL,
    [ActivityOutput]		[NVARCHAR](MAX) NULL,
	[OutputMessage]			NVARCHAR(MAX) NULL,
	[OutputError]			NVARCHAR(MAX) NULL,
	CONSTRAINT [PK_adf_TestExecutionError] PRIMARY KEY CLUSTERED ([ExecutionErrorID] DESC)
);