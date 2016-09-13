/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [dbo].[GetVersion]
--WITH ENCRYPTION
AS
SET NOCOUNT ON
BEGIN
	SELECT	 [instance_name] AS [DatabaseName]
			,[type_version] AS [VersionNumber]
	FROM	[msdb].[dbo].[sysdac_instances]
	WHERE	[instance_name] = DB_NAME()
	
END
GO