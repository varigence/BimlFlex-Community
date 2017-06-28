CREATE TABLE [admin].[Diagnostics](
    [DiagnosticsUID]			UNIQUEIDENTIFIER	NOT NULL DEFAULT(NEWID()),
    [DiagnosticsCategory]		VARCHAR (50)		NOT NULL,
	[DiagnosticsKey]			VARCHAR (100)		NOT NULL,
    [DiagnosticsValue]			VARCHAR (4000)		NOT NULL,
	[DiagnosticsDate]			DATETIME			CONSTRAINT [DF_adminDiagnostics_DiagnosticsDate] DEFAULT ((GETDATE())) NOT NULL,
    CONSTRAINT [PK_admin_Diagnostics] PRIMARY KEY CLUSTERED ([DiagnosticsDate], [DiagnosticsCategory], [DiagnosticsKey])
);
