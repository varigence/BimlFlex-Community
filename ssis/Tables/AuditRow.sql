/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[AuditRow] (
    [AuditRowID]			BIGINT				IDENTITY (1, 1) NOT NULL,
    [ExecutionID]			BIGINT				NOT NULL,
	[ComponentName]			NVARCHAR(200)		NOT NULL,
    [ObjectName]			NVARCHAR(200)		NOT NULL,
    [AuditType]				VARCHAR(20)			NOT NULL,
    [RowCount]				INT					NULL,
    [DistinctRowCount]		INT					NULL,
    [AuditRowSchema]		XML					NOT NULL,
    CONSTRAINT [PK_ssis_AuditRow] PRIMARY KEY CLUSTERED ([AuditRowID] DESC)
);

