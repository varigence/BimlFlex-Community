/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[AuditRowData] (
    [AuditRowID]  BIGINT         NOT NULL,
    [RowID]       INT			 NOT NULL,
    [ColumnName]  NVARCHAR (128) NOT NULL,
    [ColumnValue] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_ssis_AuditRowData] PRIMARY KEY CLUSTERED ([AuditRowID] DESC, [RowID] ASC, [ColumnName] ASC)
);

