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