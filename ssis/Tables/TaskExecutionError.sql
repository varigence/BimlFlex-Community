CREATE TABLE [ssis].[TaskExecutionError](
	[TaskExecutionErrorID]	[bigint] IDENTITY(1,1)	NOT NULL,
	[ExecutionID]			[bigint]				NOT NULL,
	[TaskExecutionGUID]		[nchar](36)				NOT NULL,
	[TaskErrorMessage]		[nvarchar](max)			NULL,
	CONSTRAINT [PK_ssisTaskExecutionError] PRIMARY KEY CLUSTERED ([TaskExecutionErrorID] DESC)
)
GO

CREATE NONCLUSTERED INDEX [UIX_ssisTaskExecutionError_0]
    ON [ssis].[TaskExecutionError]([ExecutionID] ASC, [TaskExecutionGUID] ASC);
GO