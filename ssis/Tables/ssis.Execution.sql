/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[Execution](
    [ExecutionID]				BIGINT				IDENTITY (1, 1) NOT NULL,
    [ParentExecutionID]			BIGINT				NULL,
	[ServerExecutionID]			BIGINT				NOT NULL,
    [ParentSourceGUID]			NCHAR (36)			NULL,
    [ExecutionGUID]				NCHAR (36)			NOT NULL,
    [SourceGUID]				NCHAR (36)			NOT NULL,
	[PackageID]					INT					NULL,
	[ExecutionStatus]			VARCHAR(1)			NULL,
	[NextLoadStatus]			VARCHAR(1)			NULL,
	[StartTime]					DATETIMEOFFSET(7)	CONSTRAINT [DF_ssisExecution_StartTime] DEFAULT (GETDATE()) NULL,
	[EndTime]					DATETIMEOFFSET(7)	NULL,
	[BatchStartTime]			DATETIME			NULL,
	[Duration]					AS					DATEDIFF(SS, [StartTime], [EndTime]) PERSISTED
    CONSTRAINT [PK_ssis_ServerExecution] PRIMARY KEY CLUSTERED ([ExecutionID] DESC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UIX_ssis_ServerExecution]
    ON [ssis].[Execution]([ExecutionGUID] ASC, [SourceGUID] ASC);