/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[ColumnInfo](
    [ColumnInfoID]				BIGINT				IDENTITY (1, 1) NOT NULL,
    [PackageID]					INT					NOT NULL,
	[LineageID]					INT					NOT NULL,
	[ColumnName]				NVARCHAR (500)		NULL,
	[CodePage]					INT					NOT NULL,
	[DataType]					NVARCHAR (50)		NOT NULL,
	[Length]					INT					NULL,
	[Precision]					INT					NULL,
	[Scale]						INT					NULL,
	[EffectiveFromDate]			DATETIME			CONSTRAINT [DF_ssisColumnInfo_StartTime] DEFAULT (GETDATE()) NOT NULL,
	[EffectiveToDate]			DATETIME			NULL,
    CONSTRAINT [PK_ssis_ColumnInfo] PRIMARY KEY CLUSTERED ([ColumnInfoID] DESC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UIX_ssis_ColumnInfo]
    ON [ssis].[ColumnInfo]([PackageID] ASC, [LineageID] ASC, [EffectiveFromDate] ASC);