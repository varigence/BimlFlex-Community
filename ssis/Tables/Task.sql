CREATE TABLE [ssis].[Task](
	[TaskID]		[int] IDENTITY(1,1)	NOT NULL,
	[PackageID]		[int]				NOT NULL,
	[TaskName]		[nvarchar](1000)	NOT NULL,
	[TaskOrder]		[smallint]			NULL,
	[AvgDuration]	[int]				NULL,
	CONSTRAINT [PK_ssisPackageTask] PRIMARY KEY CLUSTERED ([TaskID] ASC)
)
GO

CREATE NONCLUSTERED INDEX [UIX_ssisTask_0]
    ON [ssis].[Task]([PackageID] ASC, [TaskName] ASC);

