/*
# Copyright (C) 2015 Varigence, Inc.
#
# Licensed under the Varigence IP BimlFlex Framework Agreement, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License by contacting support@varigence.com.
*/
CREATE PROCEDURE [adf].[LogActivityOutput](
    @ExecutionID			[bigint],
    @ActivityName			[NVARCHAR](200) = NULL,
    @ActivityOutput			[NVARCHAR](MAX) = NULL,
    @RowsRead				[BIGINT] = NULL,
    @RowsCopied				[BIGINT] = NULL
) 
AS
BEGIN TRY
	
	MERGE [adf].[ActivityOutput] AS TARGET
	USING 
	(
		SELECT
	@ExecutionID			AS ExecutionID,
    @ActivityName			AS ActivityName,
    @ActivityOutput			AS ActivityOutput,
    @RowsRead				AS RowsRead,
    @RowsCopied				AS RowsCopied
	) AS SOURCE
		ON	TARGET.[ExecutionID] = SOURCE.[ExecutionID] 
		AND	TARGET.ActivityName = SOURCE.ActivityName COLLATE Latin1_General_CS_AS

	WHEN MATCHED THEN 
		UPDATE 
		SET		 ActivityOutput = SOURCE.ActivityOutput
				,RowsRead = SOURCE.RowsRead
				,RowsCopied = SOURCE.RowsCopied
	WHEN NOT MATCHED THEN
		INSERT	([ExecutionID]
				,ActivityName
				,ActivityOutput
				,RowsRead
				,RowsCopied)
		VALUES	(SOURCE.[ExecutionID]
				,SOURCE.ActivityName
				,SOURCE.ActivityOutput
				,SOURCE.RowsRead
				,SOURCE.RowsCopied);

	RETURN(0);
END TRY

BEGIN CATCH
    RETURN ERROR_NUMBER();
END CATCH;