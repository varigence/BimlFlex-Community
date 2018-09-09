/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TABLE [adf].[ActivityOutput] (
    [ActivityOutputID]		BIGINT IDENTITY (1, 1) NOT NULL,
    [ExecutionID]			BIGINT NOT NULL,
    ActivityName			NVARCHAR(200) NULL,
    ActivityOutput			NVARCHAR(MAX) NULL,
    RowsRead				BIGINT NULL,
    RowsCopied				BIGINT NULL

	CONSTRAINT [PK_adf_ActivityOutput] PRIMARY KEY CLUSTERED ([ActivityOutputID] DESC)
);