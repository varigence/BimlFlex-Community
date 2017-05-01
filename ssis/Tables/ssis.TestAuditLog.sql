CREATE TABLE [ssis].[TestAuditLog](
	[TestAuditLogID]			BIGINT				IDENTITY (1, 1) NOT NULL,
    [ExecutionID]				BIGINT				NOT NULL,
	[TestEntity]				NVARCHAR (300)		NOT NULL,
	[TestName]					NVARCHAR (100)		NOT NULL,
	[TestAssert]				NVARCHAR (2000)		NULL,
	[TestAssertOutput]			NVARCHAR (2000)		NULL,
	[TestConnection]			NVARCHAR (100)		NULL,
	[TestResultAssert]			NVARCHAR (2000)		NULL,
	[TestResultAssertOutput]	NVARCHAR (2000)		NULL,
	[TestResultConnection]		NVARCHAR (100)		NULL,
	[TestExpectedResult]		NVARCHAR (500)		NULL,
	[TestResultDatatype]		NVARCHAR (200)		NULL,
	[TestOperator]				NVARCHAR (100)		NULL,
	[TestMessage]				NVARCHAR (4000)		NULL,
	[TestEnvironment]			NVARCHAR (20)		NULL,
	[TestExecutionDate]			DATETIME2(7)		CONSTRAINT [DF_ssisTestAuditLog_TestExecutionDate] DEFAULT (GETDATE()) NULL,
    CONSTRAINT [PK_ssis_TestAuditLog] PRIMARY KEY CLUSTERED ([TestAuditLogID] DESC)
)
