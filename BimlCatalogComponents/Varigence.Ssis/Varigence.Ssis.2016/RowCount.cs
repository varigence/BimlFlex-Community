using System;
using System.Collections;
using System.Globalization;
using Microsoft.SqlServer.Dts.Runtime;
using Microsoft.SqlServer.Dts.Pipeline;
using Microsoft.SqlServer.Dts.Pipeline.Wrapper;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;
using System.Data.SqlClient;
using System.Data;

namespace Varigence.Ssis
{
    [
        DtsPipelineComponent
        (
            DisplayName = "Biml Row Count"
            , Description = "Counts rows of different types (Select, Insert, Update, Delete, Intermediate, Error, Truncate), and logs this via the Biml custom log provider."
            , ComponentType = 0
            , IconResource = "Varigence.Ssis.Icons.RowCount.ico"
        )]

    public class RowCount : PipelineComponent
    {
        // Fields
        SqlConnection _connection;
        private SqlCommand _cmd;
        private DataTable _columnInfo = CreateColumnInfo();
        private bool _pbCancel;
        private int _allRowCount;
        private decimal _allAggregate;
        private string _rowCountSumName;
        private int _rowCountSumIndex;
        
        // Methods
        public override void DeleteOutput(int outputID)
        {
            throw new Exception("Can't delete output " + outputID);
        }

        public override void OnInputPathAttached(int inputID)
        {
        }


        public override void PerformUpgrade(int pipelineVersion)
        {
            var num = ((DtsPipelineComponentAttribute)Attribute.GetCustomAttribute(GetType(), typeof(DtsPipelineComponentAttribute), false)).CurrentVersion;
            ComponentMetaData.Version = num;
        }

        public override void PostExecute()
        {
            var rowCountData = new RowCountSerialize
                {
                    RowCountType =
                        (RowCountSerialize.RowCountTypeEnum)
                        (ComponentMetaData.CustomPropertyCollection["RowCountType"].Value),
                    RowCount = _allRowCount
                };
            if (string.IsNullOrEmpty(_rowCountSumName))
            {
                rowCountData.ColumnSum = 0;
                rowCountData.ColumnName = "";

            }
            else
            {
                rowCountData.ColumnSum = _allAggregate;
                rowCountData.ColumnName = _rowCountSumName;
            }
            rowCountData.RowCountComponent = ComponentMetaData.Name;
            rowCountData.RowCountObject = (string)(ComponentMetaData.CustomPropertyCollection["RowCountObject"].Value);

            VariableDispenser.LockForRead("User::ExecutionID");
            IDTSVariables100 variables;
            VariableDispenser.GetVariables(out variables);

            if (variables.Locked)
            {
                rowCountData.ExecutionID = (Int64)variables["User::ExecutionID"].Value;
                variables.Unlock();
            }

            _cmd.Parameters["@ExecutionID"].Value = rowCountData.ExecutionID;
            _cmd.Parameters["@ComponentName"].Value = rowCountData.RowCountComponent;
            _cmd.Parameters["@ObjectName"].Value = rowCountData.RowCountObject;
            _cmd.Parameters["@CountType"].Value = rowCountData.RowCountTypeString;
            _cmd.Parameters["@RowCount"].Value = rowCountData.RowCount;
            _cmd.Parameters["@ColumnSum"].Value = rowCountData.ColumnSum;
            _cmd.Parameters["@ColumnName"].Value = rowCountData.ColumnName;
            _cmd.ExecuteNonQuery();

            if (_columnInfo == null || _columnInfo.Rows.Count == 0) return;
            var cmd = new SqlCommand("[ssis].[LogColumnInfo]", _connection) {CommandType = CommandType.StoredProcedure};
            cmd.Parameters.Add(new SqlParameter("@ExecutionID", rowCountData.ExecutionID));

            var parameter = new SqlParameter("@InputColumnInfo", SqlDbType.Structured)
            {
                TypeName = "dbo.InputColumnInfo",
                Value = _columnInfo
            };
            cmd.Parameters.Add(parameter);
            cmd.CommandTimeout = 0;
            cmd.ExecuteNonQuery();
        }

        public override void PreExecute()
        {
            var input = ComponentMetaData.InputCollection[0];
            var inputColumns = input.InputColumnCollection;
            _rowCountSumName = (string) ComponentMetaData.CustomPropertyCollection["RowCountSum"].Value;

            _cmd = new SqlCommand("ssis.LogRowCount", _connection) {CommandType = CommandType.StoredProcedure};
            SqlCommandBuilder.DeriveParameters(_cmd); // Creates all command parameters from the SP parameters

            foreach (IDTSInputColumn100 column in inputColumns)
            {
                _columnInfo.Rows.Add(
                    BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID),
                    column.LineageID,
                    column.Name,
                    column.DataType.ToString(),
                    column.CodePage,
                    column.Length,
                    column.Precision,
                    column.Scale
                );

                if (!string.IsNullOrEmpty(_rowCountSumName) && _rowCountSumName == column.Name)
                    _rowCountSumIndex = BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID);
            }

            _allRowCount = 0;
            _allAggregate = 0;
        }

        public override void ProcessInput(int inputID, PipelineBuffer buffer)
        {
            if (buffer.EndOfRowset) return;
            while (buffer.NextRow())
            {
                if (_rowCountSumIndex > 0)
                    _allAggregate += decimal.Parse(buffer[_rowCountSumIndex].ToString());
            }
            _allRowCount += buffer.RowCount;
        }

        public override void ProvideComponentProperties()
        {
            RemoveAllInputsOutputsAndCustomProperties();
            ComponentMetaData.UsesDispositions = false;

            var input = ComponentMetaData.InputCollection.New();
            input.Name = "RowCountInput";
            input.HasSideEffects  = true;

            var output = ComponentMetaData.OutputCollection.New();
            output.Name = "RowCountOutput";
            output.SynchronousInputID = input.ID;
            var property = ComponentMetaData.CustomPropertyCollection.New();
            property.Name = "RowCountObject";
            property.Description = "An string that identifies what the row count refers to, e.g. a fully qualified table name, a file name or an arbitrary name for an intermediate processing step. This property can be set using expressions.";
            property.ExpressionType = DTSCustomPropertyExpressionType.CPET_NOTIFY;
            var property2 = ComponentMetaData.CustomPropertyCollection.New();
            property2.Name = "RowCountType";
            property2.Description  = "The type of row count, e.g. INSERT, UPDATE etc.";
            property2.TypeConverter = typeof(RowCountSerialize.RowCountTypeEnum).AssemblyQualifiedName;
            property2.Value = RowCountSerialize.RowCountTypeEnum.Unknown;

            var property3 = ComponentMetaData.CustomPropertyCollection.New();
            property3.Name = "RowCountSum";
            property3.Description = "When specified will be the column to sum";
            property3.TypeConverter =  typeof(string).AssemblyQualifiedName;

            var connection = ComponentMetaData.RuntimeConnectionCollection.New();
            connection.Name = "BimlCatalog";
        }

        public override void AcquireConnections(object transaction)
        {
            if (ComponentMetaData.RuntimeConnectionCollection.Count <= 0) return;
            if (ComponentMetaData.RuntimeConnectionCollection[0].ConnectionManager == null) return;
            var cm = DtsConvert.GetWrapper(ComponentMetaData.RuntimeConnectionCollection[0].ConnectionManager);
            var bimlCatalog = cm.InnerObject as ConnectionManagerAdoNet;

            if (bimlCatalog == null)
                throw new Exception("The ConnectionManager " + cm.Name + " is not an ADO.NET connection.");

            _connection = bimlCatalog.AcquireConnection(transaction) as SqlConnection;
            if (_connection == null || _connection.State == ConnectionState.Open) return;
            _connection.Open();
        }

        public override void ReleaseConnections()
        {
            if (_connection != null && _connection.State != ConnectionState.Closed)
            {
                _connection.Close();
            }
        }

        public override IDTSInputColumn100 SetUsageType(int inputID, IDTSVirtualInput100 virtualInput, int lineageID, DTSUsageType usageType)
        {
            if (usageType == DTSUsageType.UT_READWRITE)
            {
                throw new Exception("Columns must be READ ONLY");
            }
            return base.SetUsageType(inputID, virtualInput, lineageID, usageType);
        }

        public override DTSValidationStatus Validate()
        {

            if (ComponentMetaData.InputCollection.Count != 1)
            {
                ComponentMetaData.FireError(0, ComponentMetaData.Name, "Incorrect number of inputs. Only one input can be used.", "", 0, out _pbCancel);
                return DTSValidationStatus.VS_ISCORRUPT;
            }
            if ((ComponentMetaData.CustomPropertyCollection["RowCountObject"].Value == null) || (ComponentMetaData.CustomPropertyCollection["RowCountObject"].Value.ToString().Length == 0))
            {
                ComponentMetaData.FireError(0, "RowCountObject", "The RowCountObject property must be set.", "", 0, out _pbCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }
            //	If there is an input column that no longer exists in the Virtual input collection,
            // return needs new meta data. The designer will then call ReinitalizeMetadata which will clean up the input collection.
            if (ComponentMetaData.AreInputColumnsValid == false)
            {
                return DTSValidationStatus.VS_NEEDSNEWMETADATA;
            }

            // Check that only one Input column exist in the collection:
            if (ComponentMetaData.InputCollection[0].InputColumnCollection.Count > 1)
            {
                ComponentMetaData.FireError(0, "RowCountObject", "Currently only one input column can be selected. This column must be numeric and will be aggregated.", "", 0, out _pbCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }
            // Check each Input column in the collection:
            // Validate column datatype.

            if (ComponentMetaData.InputCollection[0].InputColumnCollection.Count != 1) return base.Validate();
            var column = ComponentMetaData.InputCollection[0].InputColumnCollection[0];
            if (column.DataType == DataType.DT_CY || column.DataType == DataType.DT_I1 || column.DataType == DataType.DT_I2 || column.DataType == DataType.DT_I4 ||
                column.DataType == DataType.DT_I8 || column.DataType == DataType.DT_NUMERIC || column.DataType == DataType.DT_DECIMAL || column.DataType == DataType.DT_R4 ||
                column.DataType == DataType.DT_R8 || column.DataType == DataType.DT_UI1 || column.DataType == DataType.DT_UI2 || column.DataType == DataType.DT_UI4 ||
                column.DataType == DataType.DT_UI8) return base.Validate();
            ComponentMetaData.FireError(0, "RowCountObject", ComponentMetaData.InputCollection[0].InputColumnCollection[0].Name.ToString(CultureInfo.InvariantCulture) + " is not a numeric column. Please select a column of numeric type that you would like to aggregate.", "", 0, out _pbCancel);
            return DTSValidationStatus.VS_ISBROKEN;
        }

        public static DataTable CreateColumnInfo()
        {
            var dt = new DataTable();
            dt.Columns.Add("BufferColumnIndex", typeof(Int32));
            dt.Columns.Add("LineageID", typeof(Int32));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("CodePage", typeof(Int32));
            dt.Columns.Add("DataType", typeof(string));
            dt.Columns.Add("Length", typeof(Int32));
            dt.Columns.Add("Precision", typeof(Int32));
            dt.Columns.Add("Scale", typeof(Int32));
            return dt;
        }
    }


}
