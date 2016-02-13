/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[AuditLog](
    [Id]				BIGINT				IDENTITY (1, 1) NOT NULL,
	[AuditType]			VARCHAR(1)				NOT NULL,
	[TableName]			NVARCHAR (128)		NOT NULL,
	[KeyId]				BIGINT				NOT NULL,
	[ColumnName]		NVARCHAR (128)		NOT NULL,
    [OldValue]			NVARCHAR (4000)		NULL,
	[NewValue]			NVARCHAR (4000)		NULL,
	[ModifiedDate]		DATETIME2			CONSTRAINT [DF_appAuditLog_ModifiedDate] DEFAULT (GETDATE()) NOT NULL,
	[ModifiedBy]		NVARCHAR (128)		CONSTRAINT [DF_appAuditLog_ModifiedBy] DEFAULT (SUSER_SNAME()) NOT NULL,
	CONSTRAINT [PKC_ssisAuditLog] PRIMARY KEY CLUSTERED ([Id] DESC),
);
GO

