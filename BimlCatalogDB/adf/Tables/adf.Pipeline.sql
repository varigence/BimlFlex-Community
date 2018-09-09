/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [adf].[Pipeline] (
    [PipelineID]              INT           IDENTITY (1, 1) NOT NULL,
    [Pipeline]                VARCHAR (255) NOT NULL,
    [DataFactory]             VARCHAR (255) NOT NULL,
	[ProjectName]			  VARCHAR(255)  CONSTRAINT [DF_adfPipeline_ProjectName] DEFAULT (('Not Specified')) NOT NULL,
    [PipelineRetryCount]      SMALLINT      CONSTRAINT [DF_adfPipeline_PipelineRetryCount] DEFAULT ((0)) NULL,
    [PipelineExecutionCount]  INT           CONSTRAINT [DF_adfPipeline_PipelineExecutionCount] DEFAULT ((0)) NULL,
    [PipelineDurationHistory] VARCHAR (255) NULL,
    [PipelineDurationAverage] INT           NULL,
	[IsBatch]                 BIT           CONSTRAINT [DF_adfPipeline_IsBatch] DEFAULT ((0)) NULL,
    [IsEnabled]               BIT           CONSTRAINT [DF_adfPipeline_IsEnabled] DEFAULT ((1)) NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_adfPipeline_CreatedDate] DEFAULT (GETUTCDATE()) NOT NULL,
    CONSTRAINT [PK_adfPipeline] PRIMARY KEY CLUSTERED ([PipelineID] DESC)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [UIX_adfPipeline]
    ON [adf].[Pipeline]([DataFactory] ASC, [Pipeline] ASC);
