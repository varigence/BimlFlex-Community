/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[ConfigVariable] (
    [ConfigVariableID] INT           IDENTITY (1, 1) NOT NULL,
    [SystemName]       VARCHAR (100) DEFAULT ('Default') NOT NULL,
    [ObjectName]       VARCHAR (500) DEFAULT ('Default') NOT NULL,
    [VariableName]     VARCHAR (100) NOT NULL,
    [VariableValue]    VARCHAR (200) NOT NULL,
	[PreviousValue]    VARCHAR (200) NOT NULL,
	[RollbackValue]    VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_ssis_ConfigVariable] PRIMARY KEY CLUSTERED ([ConfigVariableID] ASC)
);