/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [adf].[AuditConfigVariable] (
    [AuditConfigVariableID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ConfigVariableID]      INT           NOT NULL,
    [SystemName]            VARCHAR (100) DEFAULT ('Default') NOT NULL,
    [ObjectName]            VARCHAR (500) DEFAULT ('Default') NOT NULL,
    [VariableName]          VARCHAR (100) NOT NULL,
    [VariableValue]         VARCHAR (200) NOT NULL,
    [ExecutionID]           BIGINT        NULL,
    [PreviousValue]         VARCHAR (200) NULL,
    [RowLastModified]       DATETIME2 (7) CONSTRAINT [DF_adfAuditConfigVariable_RowLastModified] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_adf_AuditConfigVariable] PRIMARY KEY CLUSTERED ([AuditConfigVariableID] ASC)
);

GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_adfAuditConfigVariable_0]
    ON [adf].[AuditConfigVariable]([ConfigVariableID] ASC, [RowLastModified] ASC);

