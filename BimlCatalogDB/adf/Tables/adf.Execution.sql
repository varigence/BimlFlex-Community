/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [adf].[Execution] (
    [ExecutionID]            BIGINT             IDENTITY (1, 1) NOT NULL,
    [ParentExecutionID]		 BIGINT             NULL,
    [DataFactory]            NVARCHAR (65)      NULL,
    [Pipeline]               NVARCHAR (2000)    NULL,
    [RunId]                  NVARCHAR (100)     NULL,
    [TriggerType]            NVARCHAR (100)     NULL,
    [TriggerId]              NVARCHAR (100)     NULL,
    [TriggerName]            NVARCHAR (100)     NULL,
    [TriggerTime]            NVARCHAR (100)     NULL,
    [TriggerScheduledTime]   NVARCHAR (100)     NULL,
    [TriggerStartTime]       NVARCHAR (100)     NULL,
    [TriggerWindowStartTime] NVARCHAR (100)     NULL,
    [TriggerWindowEndTime]   NVARCHAR (100)     NULL,
	[PipelineID]             INT                NULL,
    [ExecutionStatus]        VARCHAR (1)        NULL,
    [NextLoadStatus]         VARCHAR (1)        NULL,
    [StartTime]              DATETIMEOFFSET (7) CONSTRAINT [DF_adfExecution_StartTime] DEFAULT (GETUTCDATE()) NULL,
    [EndTime]                DATETIMEOFFSET (7) NULL,
    [BatchStartTime]         DATETIMEOFFSET (7) NULL,

    CONSTRAINT [PK_adf_Execution] PRIMARY KEY CLUSTERED ([ExecutionID] DESC)
);

