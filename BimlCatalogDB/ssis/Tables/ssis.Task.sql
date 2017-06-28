CREATE TABLE [ssis].[Task](
	[TaskID]				INT					IDENTITY(1,1)	NOT NULL,
	[PackageID]				INT					NOT NULL,
	[TaskName]				NVARCHAR(1000)		NOT NULL,
	[TaskOrder]				SMALLINT			NULL,
	[TaskExecutionCount]	INT					CONSTRAINT [DF_ssisTask_TaskExecutionCount] DEFAULT ((0)) NULL,
	[TaskDurationHistory]	VARCHAR(255)		NULL,
	[TaskDurationAverage]	INT					NULL,
	CONSTRAINT [PK_ssisTask] PRIMARY KEY CLUSTERED ([TaskID] ASC)
)
GO

CREATE NONCLUSTERED INDEX [UIX_ssisTask_0]
    ON [ssis].[Task]([PackageID] ASC, [TaskName] ASC);

