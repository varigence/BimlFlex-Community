using System;
using System.Data;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Xml;
using Microsoft.SqlServer.Dts.Runtime;
using Microsoft.SqlServer.Dts.Pipeline;
using Microsoft.SqlServer.Dts.Pipeline.Wrapper;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;
using System.Data.SqlClient;

namespace Varigence.Ssis
{
    [
        DtsPipelineComponent
            (
            DisplayName = "Biml Row Audit"
            , Description = "Logs data audit rows as XML via the Biml Log Provider. Can log distinct rows"
            , ComponentType = 0
            , IconResource = "Varigence.Ssis.Icons.AuditRow.ico"
            )]
    public class AuditRow : PipelineComponent
    {
        #region Private Variables

        private SqlConnection _connection;
        private SqlCommand _cmd;
        private ColumnInfo[] _inputColumnInfos;
        private AuditRowDataCollection _auditRowDataCollection = new AuditRowDataCollection();
        private bool _isCancel;
        private int _rowCount;
        private int _allRowCount;
        private bool _isHardError;
        private int _limitRowsToLog;
        private StringBuilder _auditSchema;
        private XmlWriter _auditSchemaXmlWriter;
        public DateTime StartTime { get; set; }

        #endregion

        public override void OnInputPathAttached(int inputID)
        {
        }

        public override void PerformUpgrade(int pipelineVersion)
        {
            var num = ((DtsPipelineComponentAttribute) Attribute.GetCustomAttribute(GetType(), typeof (DtsPipelineComponentAttribute), false)).CurrentVersion;
            ComponentMetaData.Version = num;
        }

        public override void PostExecute()
        {
            if ((_allRowCount <= 0) ||
                (((AuditRowSerialize.AuditRowTypeEnum) ComponentMetaData.CustomPropertyCollection["AuditRowType"].Value) !=
                 AuditRowSerialize.AuditRowTypeEnum.HardError)) return;
            bool isTrue;
            ComponentMetaData.FireError(0, ComponentMetaData.Name, "Biml Row Audit: Rows were logged and RowLogType = HardError.", "", 0, out isTrue);
        }

        public override void AcquireConnections(object transaction)
        {
            if (ComponentMetaData.RuntimeConnectionCollection.Count <= 0) return;
            if (ComponentMetaData.RuntimeConnectionCollection[0].ConnectionManager == null) return;
            var cm = DtsConvert.GetWrapper(ComponentMetaData.RuntimeConnectionCollection[0].ConnectionManager);
            if (cm.InnerObject != null)
            {
                var bimlCatalog = cm.InnerObject as ConnectionManagerAdoNet;

                if (bimlCatalog == null)
                    throw new Exception("The ConnectionManager " + cm.Name + " is not an ADO.NET connection.");

                _connection = bimlCatalog.AcquireConnection(transaction) as SqlConnection;
            }
            if (_connection == null || _connection.State == ConnectionState.Open) return;
            _connection.Open();
        }

        public override void ReleaseConnections()
        {
            if (_connection != null && _connection.State != ConnectionState.Closed)
                _connection.Close();
        }

        public override void PreExecute()
        {
            _allRowCount = 0;
            _limitRowsToLog = (int) ComponentMetaData.CustomPropertyCollection["LimitNumberOfRowsToLog"].Value;
            var input = ComponentMetaData.InputCollection[0];
            _inputColumnInfos = new ColumnInfo[input.InputColumnCollection.Count];
            _auditSchema = new StringBuilder();

            _cmd = new SqlCommand("ssis.LogAuditRow", _connection)
            {
                CommandType = CommandType.StoredProcedure
            };
            _cmd.Parameters.Add("@ExecutionID", SqlDbType.BigInt);
            _cmd.Parameters.Add("@ComponentName", SqlDbType.NVarChar, 200);
            _cmd.Parameters.Add("@ObjectName", SqlDbType.NVarChar, 200);
            _cmd.Parameters.Add("@AuditType", SqlDbType.VarChar, 30);
            _cmd.Parameters.Add("@RowCount", SqlDbType.Int);
            _cmd.Parameters.Add("@AuditRowSchema", SqlDbType.Xml);

            var param = new SqlParameter("@AuditRowData", SqlDbType.Structured) {TypeName = "dbo.AuditRowDataType"};
            _cmd.Parameters.Add(param);

            var settings = new XmlWriterSettings {ConformanceLevel = ConformanceLevel.Fragment};
            _auditSchemaXmlWriter = XmlWriter.Create(_auditSchema, settings);
            _auditSchemaXmlWriter.WriteStartElement("schema");
            for (var i = 0; i < input.InputColumnCollection.Count; i++)
            {
                var column = input.InputColumnCollection[i];
                _inputColumnInfos[i] = new ColumnInfo
                {
                    BufferColumnIndex = BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID),
                    ColumnDisposition = column.ErrorRowDisposition,
                    LineageID = column.LineageID,
                    Name = column.Name,
                    DataType = column.DataType.ToString(),
                    CodePage = column.CodePage,
                    Length = column.Length,
                    Precision = column.Precision,
                    Scale = column.Scale
                };
                _auditSchemaXmlWriter.WriteStartElement("column");
                _auditSchemaXmlWriter.WriteAttributeString("name", column.Name);
                _auditSchemaXmlWriter.WriteAttributeString("datatype", column.DataType.ToString());
                _auditSchemaXmlWriter.WriteAttributeString("length", column.Length.ToString(CultureInfo.InvariantCulture));
                _auditSchemaXmlWriter.WriteAttributeString("codepage", column.CodePage.ToString(CultureInfo.InvariantCulture));
                _auditSchemaXmlWriter.WriteAttributeString("scale", column.Scale.ToString(CultureInfo.InvariantCulture));
                _auditSchemaXmlWriter.WriteAttributeString("precision", column.Precision.ToString(CultureInfo.InvariantCulture));
                _auditSchemaXmlWriter.WriteEndElement();
            }
            _auditSchemaXmlWriter.WriteEndElement();
            _auditSchemaXmlWriter.Close();
        }

        public override void ProcessInput(int inputID, PipelineBuffer buffer)
        {
            if (buffer.EndOfRowset) return;
            BeginMessage();
            while (buffer.NextRow())
            {
                if (_rowCount == 1000)
                {
                    EndMessage();
                }
                _rowCount++;
                _allRowCount++;
                if ((_limitRowsToLog > 0) && (_allRowCount > _limitRowsToLog))
                {
                    _isHardError = true;
                }
                else
                {
                    foreach (var info in _inputColumnInfos)
                    {
                        _auditRowDataCollection.Add(buffer.IsNull(info.BufferColumnIndex)
                                    ? new AuditRowData(_rowCount, info.Name, "")
                                    : new AuditRowData(_rowCount, info.Name, buffer[info.BufferColumnIndex].ToString()));
                        //switch (info.Name)
                        //{
                        //    case "ErrorCode":
                        //        var errorDescription = ComponentMetaData.GetErrorDescription(buffer.GetInt32(info.BufferColumnIndex));
                        //        if (string.IsNullOrEmpty(errorDescription))
                        //        {
                        //            _auditRowDataCollection.Add(new AuditRowData(_rowCount, "ErrorDescription",
                        //                errorDescription));
                        //        }
                        //        break;
                        //    case "ErrorColumn":
                        //        var errorColumnId = buffer[info.BufferColumnIndex].ToString();
                        //        if (string.IsNullOrEmpty(errorColumnId))
                        //        {
                        //            //var errorColumn = input.InputColumnCollection.GetInputColumnByLineageID(info.LineageID);
                        //            _auditRowDataCollection.Add(new AuditRowData(_rowCount, "ErrorColumn", errorColumnId));
                        //        }
                        //        break;
                        //    default:
                        //        _auditRowDataCollection.Add(buffer.IsNull(info.BufferColumnIndex)
                        //            ? new AuditRowData(_rowCount, info.Name, "")
                        //            : new AuditRowData(_rowCount, info.Name, buffer[info.BufferColumnIndex].ToString()));
                        //        break;
                        //}
                    }
                }
            }

            EndMessage();

            if (!_isHardError) return;
            bool isTrue;
            ComponentMetaData.FireError(0, ComponentMetaData.Name, "Biml Row Audit: Too many rows logged, LimitNumberOfRowsToLog is negative and exceeded.", "", 0, out isTrue);
        }

        public override void ProvideComponentProperties()
        {
            RemoveAllInputsOutputsAndCustomProperties();
            ComponentMetaData.UsesDispositions = false;
            var input = ComponentMetaData.InputCollection.New();
            input.Name = "AuditRowInput";
            input.HasSideEffects = true;
            //var propertyDistinct = ComponentMetaData.CustomPropertyCollection.New();
            //propertyDistinct.Name = "AuditDistinct";
            //propertyDistinct.Description = "Indicates if only distinct rows should be logged.";
            //propertyDistinct.TypeConverter = typeof(AuditRowSerialize.AuditRowDistinctEnum).AssemblyQualifiedName;
            //propertyDistinct.Value = AuditRowSerialize.AuditRowDistinctEnum.Distinct;

            var propertyObject = ComponentMetaData.CustomPropertyCollection.New();
            propertyObject.Name = "AuditRowObject";
            propertyObject.Description = "An arbitrary string that identifies where the rows were logged, usually a table name or a description of an intermediate step.";
            var propertyRowType = ComponentMetaData.CustomPropertyCollection.New();
            propertyRowType.Name = "AuditRowType";
            propertyRowType.Description = "The type of row logged, e.g. HardError (stop processing), SoftError, Warning etc.";
            propertyRowType.TypeConverter = typeof (AuditRowSerialize.AuditRowTypeEnum).AssemblyQualifiedName;
            propertyRowType.Value = AuditRowSerialize.AuditRowTypeEnum.Unknown;
            var propertyLimit = ComponentMetaData.CustomPropertyCollection.New();
            propertyLimit.Name = "LimitNumberOfRowsToLog";
            propertyLimit.Description =
                "Maximum rows to log. 0 equates to unlimited number of rows. >0 will discard rows when the limit is reached. <0 will both discard rows and fail the component when ABS(LimitNumberOfRowsToLog) is reached (irrespective of the setting of RowLogType), and will promote Warning and SoftError to HardError in the logging data.";
            propertyLimit.ExpressionType = DTSCustomPropertyExpressionType.CPET_NOTIFY;
            propertyLimit.TypeConverter = typeof (int).AssemblyQualifiedName;
            propertyLimit.Value = 0;

            var connection = ComponentMetaData.RuntimeConnectionCollection.New();
            connection.Name = "BimlCatalog";
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
            if (ComponentMetaData.OutputCollection.Count != 0)
            {
                ComponentMetaData.FireError(0, ComponentMetaData.Name, "The component should not have any output objects.", "", 0, out _isCancel);
                return DTSValidationStatus.VS_ISCORRUPT;
            }
            if (ComponentMetaData.InputCollection.Count != 1)
            {
                ComponentMetaData.FireError(0, "InputCollection", "There should be one and only input to the component.", "", 0, out _isCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }
            if ((ComponentMetaData.CustomPropertyCollection["AuditRowObject"].Value == null) ||
                (ComponentMetaData.CustomPropertyCollection["AuditRowObject"].Value.ToString().Length == 0))
            {
                ComponentMetaData.FireError(0, "AuditRowObject", "AuditRowObject must be set.", "", 0, out _isCancel);
                return DTSValidationStatus.VS_ISBROKEN;
            }
            return !ComponentMetaData.AreInputColumnsValid ? DTSValidationStatus.VS_ISVALID : base.Validate();
        }

        private void BeginMessage()
        {
            _rowCount = 0;
            StartTime = DateTime.Now;
        }

        private void EndMessage()
        {
            if (_rowCount <= 0) return;
            var auditRowData = new AuditRowSerialize
            {
                AuditRowType =
                    (AuditRowSerialize.AuditRowTypeEnum)
                        ComponentMetaData.CustomPropertyCollection["AuditRowType"].Value
            };
            if (_isHardError &&
                ((auditRowData.AuditRowType == AuditRowSerialize.AuditRowTypeEnum.SoftError) || (auditRowData.AuditRowType == AuditRowSerialize.AuditRowTypeEnum.Warning)))
            {
                auditRowData.AuditRowType = AuditRowSerialize.AuditRowTypeEnum.HardError;
            }
            auditRowData.RowCount = _rowCount;
            auditRowData.AuditRowComponent = ComponentMetaData.Name;
            auditRowData.AuditRowObject = (string) ComponentMetaData.CustomPropertyCollection["AuditRowObject"].Value;
            auditRowData.AuditRowSchema = _auditSchema.ToString();
            auditRowData.AuditRowData = _auditRowDataCollection;

            VariableDispenser.LockForRead("User::ExecutionID");
            IDTSVariables100 variables;
            VariableDispenser.GetVariables(out variables);

            if (variables.Locked)
            {
                auditRowData.ExecutionID = (Int64) variables["User::ExecutionID"].Value;
                variables.Unlock();
            }

            _cmd.Parameters["@ExecutionID"].Value = auditRowData.ExecutionID;
            _cmd.Parameters["@ComponentName"].Value = auditRowData.AuditRowComponent;
            _cmd.Parameters["@ObjectName"].Value = auditRowData.AuditRowObject;
            _cmd.Parameters["@AuditType"].Value = auditRowData.AuditRowTypeString;
            _cmd.Parameters["@RowCount"].Value = auditRowData.RowCount;
            _cmd.Parameters["@AuditRowSchema"].Value = auditRowData.AuditRowSchema;
            _cmd.Parameters["@AuditRowData"].Value = auditRowData.AuditRowData;
            _cmd.ExecuteNonQuery();
            _rowCount = 0;
            _auditRowDataCollection.Clear();
        }

        // Nested Types
        //[StructLayout(LayoutKind.Sequential)]
        public struct ColumnInfo
        {
            public int BufferColumnIndex;
            public DTSRowDisposition ColumnDisposition;
            public int LineageID;
            public string Name;
            public int CodePage;
            public string DataType;
            public int Length;
            public int Precision;
            public int Scale;
        }

    }
}
