﻿/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [ssis].[Application](
	[ApplicationId]		INT					IDENTITY (1, 1) NOT NULL,	
	[ApplicationName]	VARCHAR(255)		NOT NULL,
	CONSTRAINT [PK_ssisApplication] PRIMARY KEY CLUSTERED ([ApplicationId] ASC)
)
