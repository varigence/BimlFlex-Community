/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ssis].[Application]'))
	DROP TABLE [ssis].[Application]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ssis].[Batch]'))
	DROP TABLE [ssis].[Batch]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ssis].[PackageExecution]'))
	DROP TABLE [ssis].[PackageExecution]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ssis].[PackageError]'))
	DROP TABLE [ssis].[PackageError]
GO

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[ssis].[ConfigVariable]') AND name = N'PreviousExecutionID')
BEGIN
	ALTER TABLE [ssis].[ConfigVariable] DROP COLUMN  [PreviousExecutionID]
END
GO

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[ssis].[AuditRow]') AND name = N'DistinctRowCount')
BEGIN
	ALTER TABLE [ssis].[AuditRow] DROP COLUMN  [DistinctRowCount]
END
GO

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[ssis].[ConfigVariable]') AND name = N'RollbackValue')
BEGIN
	ALTER TABLE [ssis].[ConfigVariable] DROP COLUMN  [RollbackValue]
END
GO

IF EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[ssis].[ConfigVariable]') AND name = N'RollbackExecutionID')
BEGIN
	ALTER TABLE [ssis].[ConfigVariable] DROP COLUMN  [RollbackExecutionID]
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sysssislog]'))
	CREATE TABLE [dbo].[sysssislog] (
		[id]          INT              IDENTITY (1, 1) NOT NULL,
		[event]       [sysname]        NOT NULL,
		[computer]    NVARCHAR (128)   NOT NULL,
		[operator]    NVARCHAR (128)   NOT NULL,
		[source]      NVARCHAR (1024)  NOT NULL,
		[sourceid]    UNIQUEIDENTIFIER NOT NULL,
		[executionid] UNIQUEIDENTIFIER NOT NULL,
		[starttime]   DATETIME         NOT NULL,
		[endtime]     DATETIME         NOT NULL,
		[datacode]    INT              NOT NULL,
		[databytes]   IMAGE            NULL,
		[message]     NVARCHAR (2048)  NOT NULL,
		PRIMARY KEY CLUSTERED ([id] ASC)
	);
GO

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sysssislog]') AND CONVERT(INT, LEFT(CONVERT(VARCHAR, SERVERPROPERTY('productversion')), 2)) >= 11)
--	DROP TABLE [dbo].[sysssislog]
--GO