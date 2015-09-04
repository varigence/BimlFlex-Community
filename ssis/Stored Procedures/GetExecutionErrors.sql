CREATE PROCEDURE [dbo].[GetExecutionErrors]
	-- Add the parameters for the stored procedure here
	@ExecutionID VARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ee.[ExecutionErrorID]
		  ,ee.[PackageID]
		  ,p.[PackageName]
		  ,ee.[ExecutionID]
		  ,ee.[ErrorCode]
		  ,ee.[ErrorDescription] 
	FROM [BimlCatalog].[ssis].[ExecutionError] ee
	INNER JOIN [BimlCatalog].[ssis].[Package] p ON ee.[PackageID] = p.[PackageID]
	WHERE ee.[ExecutionID] = @ExecutionID

END