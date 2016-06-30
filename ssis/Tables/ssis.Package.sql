/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[Package](
	[PackageID]					INT					IDENTITY (1, 1) NOT NULL,
	[PackageName]				VARCHAR(255)		NOT NULL,
	[ProjectName]				VARCHAR(255)		CONSTRAINT [DF_ssisPackage_ProjectName] DEFAULT (('Not Specified')) NOT NULL,
	[ParentPackageID]			INT					NULL,
	[PrecedencePackageID]		INT					NULL,
	[PackageFolder]				VARCHAR(255)		NULL,
	[PackageRetryCount]			SMALLINT			CONSTRAINT [DF_ssisPackage_PackageRetryCount] DEFAULT ((0)) NULL,
	[PackageExecutionCount]		SMALLINT			CONSTRAINT [DF_ssisPackage_PackageExecutionCount] DEFAULT ((0)) NULL,
	[PackageExecutionDuration]	SMALLINT			CONSTRAINT [DF_ssisPackage_PackageExecutionDuration] DEFAULT ((0)) NULL,
	[IsBatch]					BIT					CONSTRAINT [DF_ssisPackage_IsBatch] DEFAULT ((0)) NULL,
	[IsEnabled]					BIT					CONSTRAINT [DF_ssisPackage_IsEnabled] DEFAULT ((1)) NULL,
	[ExecutionOrder]			SMALLINT			CONSTRAINT [DF_ssisPackage_ExecutionOrder] DEFAULT ((0)) NOT NULL,
	--[CreatedBy]					VARCHAR(100)		CONSTRAINT [DF_ssisPackage_CreatedBy] DEFAULT ((SUSER_NAME())) NOT NULL,
	[CreatedDate]				DATETIME			CONSTRAINT [DF_ssisPackage_CreatedDate] DEFAULT ((GETDATE())) NOT NULL,
	--[UpdatedBy]					VARCHAR(100)		CONSTRAINT [DF_ssisPackage_UpdatedBy] DEFAULT ((SUSER_NAME())) NOT NULL,
	--[UpdatedDate]				DATETIME			CONSTRAINT [DF_ssisPackage_UpdatedDate] DEFAULT ((GETDATE())) NOT NULL,
	CONSTRAINT [PK_ssisPackage] PRIMARY KEY CLUSTERED ([PackageID] DESC)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [UIX_ssisPackage_0]
    ON [ssis].[Package]([ProjectName] ASC, [PackageName] ASC);