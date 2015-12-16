/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE TYPE [dbo].[InputColumnInfo] AS TABLE (
    [BufferColumnIndex]     INT				NOT NULL,
	[LineageID]				INT				NOT NULL,
	[Name]					NVARCHAR (500)	NULL,
	[CodePage]				INT				NOT NULL,
	[DataType]				NVARCHAR (50)	NULL,
	[Length]				INT				NOT NULL,
	[Precision]				INT				NOT NULL,
	[Scale]					INT				NOT NULL)