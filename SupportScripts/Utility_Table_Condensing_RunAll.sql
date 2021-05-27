/* *********************************************
* Disclaimer and License
* Use this executable script at your own risk!
* THIS SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL VARIGENCE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THIS SCRIPT OR THE USE OR OTHER DEALINGS IN THIS SCRIPT.
* ******************************************** */

/*    
On this script:
- This script can be used to create a maintenance procedure that calls the table condensing procedure, also in the maintenance schema.
- The script is to assist troubleshooting and performance management at database level.
- It is part of BimlFlex community and not supported by Varigence.
*/

-- Create maintenance schema, if it doesn't exist yet
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'maintenance')
BEGIN
EXEC('CREATE SCHEMA maintenance')
END;
GO

CREATE PROCEDURE maintenance.TableCondensingAll AS

DECLARE @TableName VARCHAR(256);
DECLARE @SchemaName VARCHAR(256);

DECLARE table_cursor CURSOR FOR
SELECT TABLE_NAME, TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES

OPEN table_cursor

FETCH NEXT FROM table_cursor
INTO @TableName, @SchemaName

WHILE @@FETCH_STATUS = 0
BEGIN

EXEC	[maintenance].[CondenseTable]
		@SchemaName = @SchemaName,
		@Table = @TableName

FETCH NEXT FROM table_cursor INTO @TableName, @SchemaName

END
CLOSE table_cursor
DEALLOCATE table_cursor