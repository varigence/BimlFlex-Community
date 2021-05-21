/* *********************************************
* Disclaimer and License
* Use this executable script at your own risk!
* THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL VARIGENCE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THIS SCRIPT OR THE USE OR OTHER DEALINGS IN THIS SCRIPT.
* ******************************************** */

/*    
On this script:
- This script can be used to enable/disable PAGE compression on existing objects. Filters can be changed to match the intended selection or outcome.
- The script is to assist troubleshooting and performance management at database level.
- It is part of BimlFlex community and not supported by Varigence.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE @Compression VARCHAR(3)
DECLARE @CompressionFlag INT
DECLARE @TargetTableType VARCHAR(4)
DECLARE @IndexName VARCHAR(255)
DECLARE @IndexType VARCHAR(2)
DECLARE @TableName VARCHAR(255)
DECLARE @SchemaName VARCHAR(255)
DECLARE @SQL10 VARCHAR(MAX)

-- Flag to enable or disable compression
SET @Compression = 'On'

--SET @SchemaName = 'schemaname'
--SET @TableName  = 'tablename' -- for testing with one table

DECLARE Table_Cursor CURSOR FOR
	SELECT
	   sys.tables.name AS [TableName]
	  ,sys.indexes.name AS [IndexName]
	  ,LEFT(sys.indexes.name, 2) AS [IndexType]	 
	  --,sys.partitions.rows AS [Table_Rows]
	  ,ISNULL(sys.partitions.data_compression, 0) AS [CompressionFlag]
      ,sys.schemas.name AS [Schema]
	FROM sys.tables
	LEFT OUTER JOIN sys.partitions ON sys.tables.object_id = sys.partitions.object_id
	LEFT OUTER JOIN sys.indexes ON sys.partitions.object_id = sys.indexes.object_id
    LEFT OUTER JOIN sys.schemas ON sys.schemas.schema_id = sys.tables.schema_id
	  AND sys.partitions.index_id = sys.indexes.index_id
	WHERE OBJECTPROPERTY(sys.tables.OBJECT_ID,'ismsshipped') = 0
	 AND sys.schemas.name IN ('rdv')
      --AND sys.tables.Name = @TableName -- for testing with one table
	  AND sys.partitions.data_compression =
		CASE @Compression --Filter on compression enabling, 0 means there is no compression so it's turned on
			WHEN 'On' THEN 0
			WHEN 'Off' THEN 1
		END
OPEN Table_Cursor
FETCH NEXT FROM Table_Cursor INTO @TableName, @IndexName, @IndexType, @CompressionFlag, @SchemaName
WHILE @@FETCH_STATUS = 0
   BEGIN
	SET @SQL10 = ''
	IF @IndexType = 'PK' AND @Compression='Off'
		SET @SQL10=@SQL10+'ALTER INDEX [' + @IndexName + '] ON [dbo].' + @SchemaName + ' REBUILD PARTITION = ALL WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, ONLINE = OFF, SORT_IN_TEMPDB = OFF); '+CHAR(13)
	ELSE IF @IndexType = 'IX' AND @Compression='Off'
		SET @SQL10=@SQL10+'ALTER INDEX [' + @IndexName + '] ON [dbo].' + @SchemaName + ' REBUILD PARTITION = ALL WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, IGNORE_DUP_KEY  = OFF, ONLINE = OFF, SORT_IN_TEMPDB = OFF); '+CHAR(13)

	IF @IndexType = 'PK' AND @Compression='On'
			SET @SQL10= @SQL10+'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, ONLINE = OFF, SORT_IN_TEMPDB = OFF, DATA_COMPRESSION = PAGE); '+CHAR(13)
		ELSE IF @IndexType = 'IX' AND @Compression='On'
			SET @SQL10=@SQL10+'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, IGNORE_DUP_KEY = OFF, ONLINE = OFF, SORT_IN_TEMPDB = OFF, DATA_COMPRESSION = PAGE); '+CHAR(13)

	IF @Compression='Off'
		SET @SQL10 = @SQL10 + 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE); ' +CHAR(13)
    ELSE IF @Compression='On'
		SET @SQL10 = @SQL10 + 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE); '+CHAR(13)
	
    PRINT 'TableName:' + @TableName
	PRINT 'IndexName:' + @IndexName
    PRINT 'Statement:' + @SQL10
    PRINT 'Compression:' + @Compression
	EXEC (@SQL10)
	SET @SQL10=''
	
FETCH NEXT FROM Table_Cursor INTO @TableName, @IndexName, @IndexType, @CompressionFlag, @SchemaName
END
CLOSE Table_Cursor
DEALLOCATE Table_Cursor
GO