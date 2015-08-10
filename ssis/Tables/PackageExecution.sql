/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[PackageExecution](
	[PackageID]				INT			NOT NULL,
	[ExecutionID]			INT			NOT NULL,
	[ExecutionStatus]		CHAR(1)		NOT NULL,
	CONSTRAINT [PK_ssisPackageExecution] PRIMARY KEY CLUSTERED ([PackageID] DESC, [ExecutionID] DESC)
)
