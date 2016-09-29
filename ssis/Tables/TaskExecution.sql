CREATE TABLE [ssis].[TaskExecution](
	[TaskExecutionID]		BIGINT				IDENTITY(1,1)	NOT NULL,
	[ExecutionID]			BIGINT				NOT NULL,
	[TaskExecutionGUID]		NCHAR(36)			NOT NULL,
	[TaskID]				INT					NOT NULL,
	[TaskExecutionOrder]	INT					CONSTRAINT [DF_ssisPackage_TaskExecutionOrder] DEFAULT ((0)) NULL,
	[TaskExecutionDuration]	INT					NULL
	CONSTRAINT [PK_ssisTaskExecution] PRIMARY KEY CLUSTERED ([TaskExecutionID] DESC)
)
GO

CREATE NONCLUSTERED INDEX [UIX_ssisTaskExecution_0]
    ON [ssis].[TaskExecution]([ExecutionID] ASC, [TaskExecutionGUID] ASC, [TaskID] ASC);
