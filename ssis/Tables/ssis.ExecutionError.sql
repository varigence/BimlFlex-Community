CREATE TABLE [ssis].[ExecutionError](
	[ExecutionErrorID]		BIGINT			IDENTITY (1, 1) NOT NULL,
	[PackageID]				INT				NOT NULL,
	[ExecutionID]			BIGINT			NOT NULL,
	[ErrorCode]				INT				NOT NULL,
	[ErrorDescription]		NVARCHAR(MAX)	NOT NULL,
	CONSTRAINT [PK_ssisExecutionError] PRIMARY KEY CLUSTERED ([ExecutionErrorID] DESC)
)
