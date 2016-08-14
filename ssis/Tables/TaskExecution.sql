CREATE TABLE [ssis].[TaskExecution](
	[TaskExecutionID]		[bigint] IDENTITY(1,1)	NOT NULL,
	[ExecutionID]			[bigint]				NOT NULL,
	[TaskExecutionGUID]		[nchar](36)				NOT NULL,
	[TaskID]				[int]					NOT NULL,
	[TaskExecutionOrder]	[int]					NULL,
	[TaskExecutionDuration] [int]					NULL,
	CONSTRAINT [PK_ssisTaskExecution] PRIMARY KEY CLUSTERED ([TaskExecutionID] DESC)
)
GO

CREATE NONCLUSTERED INDEX [UIX_ssisTaskExecution_0]
    ON [ssis].[TaskExecution]([ExecutionID] ASC, [TaskExecutionGUID] ASC, [TaskID] ASC);
