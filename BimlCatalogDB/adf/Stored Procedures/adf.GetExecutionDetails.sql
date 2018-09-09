/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[GetExecutionDetails](
	@ExecutionID			[BIGINT]
)
AS 

-- check if run is registered
IF NOT EXISTS (SELECT 1 FROM [adf].[Execution] WHERE ExecutionID = @ExecutionID)
BEGIN
	RAISERROR ('[adf].[GetExecutionDetails] - Nonexistent Execution ID',16,1);
	RETURN;
END
ELSE
BEGIN
	-- TODO: select only required columns
	SELECT * FROM adf.Execution WHERE ExecutionID = @ExecutionID
END
