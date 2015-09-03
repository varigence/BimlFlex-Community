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