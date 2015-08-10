/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
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

