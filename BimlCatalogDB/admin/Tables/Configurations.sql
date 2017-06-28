/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [admin].[Configurations](
    [ConfigurationID]			INT					IDENTITY (1, 1) NOT NULL,
    [ConfigurationCode]			VARCHAR (20)		NOT NULL,
	[ConfigurationKey]			VARCHAR (100)		NOT NULL,
    [ConfigurationValue]		VARCHAR (4000)		NOT NULL,
	[CreatedDate]				DATETIME			CONSTRAINT [DF_adminConfigurations_CreatedDate] DEFAULT ((GETDATE())) NOT NULL,
	[UpdatedDate]				DATETIME			CONSTRAINT [DF_adminConfigurations_UpdatedDate] DEFAULT ((GETDATE())) NOT NULL,
    CONSTRAINT [PK_admin_Configurations] PRIMARY KEY CLUSTERED ([ConfigurationID] ASC)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UIX_adminConfigurations_0]
    ON [admin].[Configurations]([ConfigurationCode] ASC, [ConfigurationKey] ASC);
