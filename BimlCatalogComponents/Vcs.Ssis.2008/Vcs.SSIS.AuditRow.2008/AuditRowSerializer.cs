using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using Microsoft.SqlServer.Server;

namespace Vcs.SSIS
{
    public class AuditRowSerializer
    {
        // Fields
        protected const int LogSerializerCode = 0x4C6F6753;

        // Methods
        public object FromMemoryStream(MemoryStream stream)
        {
            var formatter = new BinaryFormatter();
            stream.Seek(0L, SeekOrigin.Begin);
            return formatter.Deserialize(stream);
        }

        public byte[] ToByteArray()
        {
            return ToMemoryStream().ToArray();
        }

        public MemoryStream ToMemoryStream()
        {
            var serializationStream = new MemoryStream();
            new BinaryFormatter().Serialize(serializationStream, this);
            return serializationStream;
        }
    }
    [Serializable]
    public class AuditRowSerialize : AuditRowSerializer
    {
        #region Private Variables

        public const int LogAuditRowCode = 0x4C6F6741;
        private static readonly string[] LogAuditRowTypeCollection = new[] { "Unknown", "HardError", "SoftError", "Warning", "InferredMember", "Information", "Debug" };
        #endregion

        #region Public Methods
        public AuditRowSerialize()
        {
            AuditRowData = new AuditRowDataCollection();
            AuditRowType = AuditRowTypeEnum.Unknown;
            RowCount = 0;
            DistinctRowCount = 0;
            AuditRowComponent = "";
            AuditRowObject = "";
            ExecutionID = -1;
            AuditRowSchema = "";
            ExecutionInstanceGuid = "";
        }

        public AuditRowSerialize(byte[] byteArray)
        {
            var stream = new MemoryStream(byteArray);
            var data = (AuditRowSerialize)FromMemoryStream(stream);
            AuditRowType = data.AuditRowType;
            RowCount = data.RowCount;
            DistinctRowCount = data.DistinctRowCount;
            AuditRowComponent = data.AuditRowComponent;
            AuditRowObject = data.AuditRowObject;
            ExecutionID = data.ExecutionID;
            AuditRowSchema = data.AuditRowSchema;
            AuditRowData = data.AuditRowData;
            ExecutionInstanceGuid = data.ExecutionInstanceGuid;

        }

        public AuditRowSerialize(string auditRowComponent, string auditRowObject, Int64 executionID, string executionInstanceGuid)
        {
            AuditRowType = AuditRowTypeEnum.Unknown;
            RowCount = 0;
            DistinctRowCount = 0;
            AuditRowComponent = auditRowComponent;
            AuditRowObject = auditRowObject;
            ExecutionID = executionID;
            AuditRowSchema = AuditRowSchema;
            AuditRowData = AuditRowData;
            ExecutionInstanceGuid = executionInstanceGuid;

        }
        #endregion

        #region Public Properties

        public int RowCount { get; set; }

        public int DistinctRowCount { get; set; }

        public Int64 ExecutionID { get; set; }

        public string AuditRowComponent { get; set; }

        public string AuditRowObject { get; set; }

        public AuditRowTypeEnum AuditRowType { get; set; }

        public string AuditRowTypeString
        {
            get { return LogAuditRowTypeCollection[(int)AuditRowType]; }
        }

        public string AuditRowSchema { get; set; }

        public AuditRowDataCollection AuditRowData { get; set; }

        public string ExecutionInstanceGuid { get; set; }

        #endregion

        #region Log Audit Row Types
        public enum AuditRowTypeEnum
        {
            Unknown,
            HardError,
            SoftError,
            Warning,
            InferredMember,
            Information,
            Debug
        }

        public enum AuditRowDistinctEnum
        {
            Distinct,
            NonDistinct
        }
        #endregion
    }


    [Serializable]
    public class AuditRowData
    {
        public Int32 RowID { get; set; }
        public string ColumnName { get; set; }
        public string ColumnValue { get; set; }

        public AuditRowData(Int32 rowID, string columnName, string columnValue)
        {
            RowID = rowID;
            ColumnName = columnName;
            ColumnValue = columnValue;
        }
    }

    [Serializable]
    public class AuditRowDataCollection : List<AuditRowData>, IEnumerable<SqlDataRecord>
    {
        IEnumerator<SqlDataRecord> IEnumerable<SqlDataRecord>.GetEnumerator()
        {
            var ret = new SqlDataRecord(
                new SqlMetaData("RowID", SqlDbType.Int),
                new SqlMetaData("ColumnName", SqlDbType.NVarChar, 128),
                new SqlMetaData("ColumnValue", SqlDbType.NVarChar, 4000)
                );

            foreach (var auditRowData in this)
            {
                ret.SetInt32(0, auditRowData.RowID);
                ret.SetString(1, auditRowData.ColumnName);
                ret.SetString(2, auditRowData.ColumnValue);
                yield return ret;
            }
        }
    }
}
