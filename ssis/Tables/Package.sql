/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[Package](
	[PackageID]				INT					IDENTITY (1, 1) NOT NULL,
	[ParentPackageID]		INT					NOT NULL,
	[CustomerUID]			UNIQUEIDENTIFIER	NULL,
	[ProjectName]			VARCHAR(255)		NOT NULL,
	[PackageFolder]			VARCHAR(255)		NOT NULL,
	[PackageName]			VARCHAR(255)		NOT NULL,
	[ExecutionOrder]		SMALLINT			CONSTRAINT [DF_ssisPackage_ExecutionOrder] DEFAULT ((0)) NOT NULL,
	[CreatedBy]				VARCHAR(100)		NOT NULL,
	[CreatedDate]			DATETIME			NOT NULL,
	[UpdatedBy]				VARCHAR(100)		NOT NULL,
	[UpdatedDate]			DATETIME			NOT NULL,
	CONSTRAINT [PK_ssisPackage] PRIMARY KEY CLUSTERED ([PackageID] DESC)
)

GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_ssisPackage_0]
    ON [ssis].[Package]([CustomerUID] ASC, [ProjectName] ASC, [PackageName] ASC);