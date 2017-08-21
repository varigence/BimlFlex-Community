using System;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;

namespace Varigence.Ssis
{
    [Serializable]
    public class RowCountSerializer
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
    public class RowCountSerialize : RowCountSerializer
    {
        #region Private Variables

        public const int LogRowCountCode = 0x4C6F6752;
        private static readonly string[] LogRowCountTypeCollection = new[] { "Unknown", "Select", "Insert", "Update", "Delete", "Unaffected", "Intermediate", "Error", "Exception", "Control" };
        #endregion

        #region Public Methods
        public RowCountSerialize()
        {
            RowCountType = RowCountTypeEnum.Unknown;
            RowCount = 0;
            ColumnSum = 0;
            ColumnName = "";
            RowCountComponent = "";
            RowCountObject = "";
            ExecutionID = -1;
            ExecutionInstanceGuid = "";
        }

        public RowCountSerialize(byte[] byteArray)
        {
            var stream = new MemoryStream(byteArray);
            var data = (RowCountSerialize)FromMemoryStream(stream);
            RowCountType = data.RowCountType;
            RowCount = data.RowCount;
            ColumnSum = data.ColumnSum;
            ColumnName = data.ColumnName;
            RowCountComponent = data.RowCountComponent;
            RowCountObject = data.RowCountObject;
            ExecutionID = data.ExecutionID;
            ExecutionInstanceGuid = data.ExecutionInstanceGuid;

        }

        public RowCountSerialize(string rowCountComponent, string rowCountObject, Int64 executionID, string executionInstanceGuid)
        {
            RowCountType = RowCountTypeEnum.Unknown;
            RowCount = 0;
            ColumnSum = 0;
            ColumnName = "";
            RowCountComponent = rowCountComponent;
            RowCountObject = rowCountObject;
            ExecutionID = executionID;
            ExecutionInstanceGuid = executionInstanceGuid;

        }
        #endregion

        #region Public Properties

        public int RowCount { get; set; }

        public decimal ColumnSum { get; set; }

        public string ColumnName { get; set; }

        public Int64 ExecutionID { get; set; }

        public string ExecutionInstanceGuid { get; set; }

        public string RowCountComponent { get; set; }

        public string RowCountObject { get; set; }

        public RowCountTypeEnum RowCountType { get; set; }

        public string RowCountTypeString
        {
            get
            {
                return LogRowCountTypeCollection != null ? LogRowCountTypeCollection[(int)RowCountType] : null;
            }
        }

        #endregion

        #region Log Row Count Types
        public enum RowCountTypeEnum
        {
            Unknown,
            Select,
            Insert,
            Update,
            Delete,
            Unaffected,
            Intermediate,
            Error,
            Exception,
            Control
        }
        #endregion
    }
}
