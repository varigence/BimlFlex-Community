/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [ssis].[GetPackageExecution]
	@StringPackageName VARCHAR(100),
	@ServerExecutionID VARCHAR(25)
AS

DECLARE @FinalPackageName VARCHAR(100) 
DECLARE @PackageNameLength INT 

SET @PackageNameLength = Len(@StringPackageName) 
SET @FinalPackageName = @StringPackageName + '.dtsx' 

SELECT [executable_id], 
       [execution_id], 
       [executable_name], 
       [executable_guid], 
       [package_name], 
       [package_path] 
FROM   [SSISDB].[catalog].[executables] 
WHERE  [execution_id] = @ServerExecutionID 
       AND executable_name <> @StringPackageName
       AND Charindex(@FinalPackageName, package_name) > 0 


GO
