using System;
using System.Collections;
using System.Globalization;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.SqlServer.Dts.Pipeline;
using Microsoft.SqlServer.Dts.Pipeline.Wrapper;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;
using Microsoft.SqlServer.Dts.Runtime;
using System.Security.Cryptography;

namespace Varigence.Ssis
{
    [
        DtsPipelineComponent
        (
            DisplayName = "Biml Hash Sql"
            , Description = "SHA1 hash of columns compatible with RDBMS."
            , ComponentType = ComponentType.Transform
            , IconResource = "Varigence.Ssis.Icons.HashSql.ico"
        )]
    public class HashSql : PipelineComponent
    {
        #region Member data

        private struct ColumnInfo
        {

            public int bufferColumnIndex;
            public DTSRowDisposition columnDisposition;

            public int lineageID;
            public string dataType;
        }

        const int INVALID_CHARACTER_INDEX = 0x1;
        const string InvalidCharacterIndexmessage = "The character index to change is outside the length of the column value.";
        private static SHA1 _sha1 = SHA1.Create();
        private string nullValue = "";
        private const Boolean millisecondHandling = true;
        //        private HashAlgorithm HashSHA1Algorithm;
        private ColumnInfo[] inputColumnInfos;
        private ColumnInfo[] outputColumnInfos;
        internal const string Hash_ALGORITHM_PROPERTY = "HashAlgorithm";

        #endregion Member data

        #region Design Time

        #region PerformUpgrade
        public override void PerformUpgrade(int pipelineVersion)
        {
            int componentVersion = ((DtsPipelineComponentAttribute)Attribute.GetCustomAttribute(GetType(), typeof(DtsPipelineComponentAttribute), false)).CurrentVersion;
            ComponentMetaData.Version = componentVersion;
            IDTSOutput100 output = base.ComponentMetaData.OutputCollection[0];

            if (output.OutputColumnCollection.Count == 1)
            {
                IDTSOutputColumn100 column = output.OutputColumnCollection[0];

                if (column.CustomPropertyCollection.Count == 0)
                {
                    IDTSCustomProperty100 property = column.CustomPropertyCollection.New();
                    property.Name = "Hash";
                    property.Description = "Hash SHA1 transformation result column indicator.";
                    property.Value = "Hash";
                }
            }
        }
        #endregion PerformUpgrade

        #region ProvideComponentProperties
        public override void ProvideComponentProperties()
        {
            ComponentMetaData.UsesDispositions = true;

            var propertyObject = ComponentMetaData.CustomPropertyCollection.New();
            propertyObject.Name = "NullValue";
            propertyObject.Description = "This value will be used to replace any Null Values when hashing.";

            //	Add the input
            IDTSInput100 input = ComponentMetaData.InputCollection.New();
            input.Name = "HashInput";
            input.ErrorRowDisposition = DTSRowDisposition.RD_FailComponent;

            //	Add the output
            IDTSOutput100 output = ComponentMetaData.OutputCollection.New();
            output.Name = "HashOutput";
            output.SynchronousInputID = input.ID;
            output.ExclusionGroup = 1;

            AddHashColumn();
        }
        #endregion ProvideComponentProperties

        #region AddHashColumn
        private void AddHashColumn()
        {
            IDTSOutputColumn100 column = base.ComponentMetaData.OutputCollection[0].OutputColumnCollection.New();
            column.Name = "Hash";
            column.SetDataTypeProperties(DataType.DT_STR, 40, 0, 0, 1252);
            IDTSCustomProperty100 property = column.CustomPropertyCollection.New();
            property.Name = "Hash";
            property.Description = "Hash SHA1 transformation result column indicator.";
            property.Value = "Hash";
        }
        #endregion AddHashColumn

        #region Validate
        public override DTSValidationStatus Validate()
        {
            if (ComponentMetaData.AreInputColumnsValid == false)
            {
                return DTSValidationStatus.VS_NEEDSNEWMETADATA;
            }

            if (!ValidateOutputColumn())
            {
                ComponentMetaData.FireWarning(0, ComponentMetaData.Name, "The output column collection is invalid and will need to be reset.", "", 0);
                return DTSValidationStatus.VS_ISBROKEN;
            }

            return base.Validate();
        }

        private bool ValidateOutputColumn()
        {
            IDTSOutput100 output = ComponentMetaData.OutputCollection[0];
            return (((output.OutputColumnCollection.Count == 1)
                && (output.OutputColumnCollection[0].DataType == DataType.DT_STR))
                && ((output.OutputColumnCollection[0].CustomPropertyCollection.Count == 1)
                && (output.OutputColumnCollection[0].CustomPropertyCollection[0].Name == "Hash")));
        }
        #endregion Validate

        #region ReinitializeMetaData
        public override void ReinitializeMetaData()
        {
            ComponentMetaData.RemoveInvalidInputColumns();
            base.ReinitializeMetaData();
            IDTSOutput100 output = ComponentMetaData.OutputCollection[0];
            if (!ValidateOutputColumn())
            {
                output.OutputColumnCollection.RemoveAll();
                AddHashColumn();
            }
        }
        #endregion ReinitializeMetaData

        #region SetUsageType
        public override IDTSInputColumn100 SetUsageType(int inputID, IDTSVirtualInput100 virtualInput, int lineageID, DTSUsageType usageType)
        {
            if (usageType == DTSUsageType.UT_READWRITE)
                throw new Exception("The UsageType must be set to Read Only.");

            return base.SetUsageType(inputID, virtualInput, lineageID, usageType);
        }
        #endregion SetUsageType

        #region DeleteOutput
        public override void DeleteOutput(int outputID)
        {
            throw new Exception("Can't delete output " + outputID.ToString(CultureInfo.InvariantCulture));
        }
        #endregion DeleteOutput

        #region InsertOutput
        public override IDTSOutput100 InsertOutput(DTSInsertPlacement insertPlacement, int outputID)
        {
            throw new Exception("Can't add output to the component.");
        }
        #endregion InsertOutput

        #endregion Design Time

        #region Runtime

        #region PreExecute
        public override void PreExecute()
        {
            IDTSInput100 input = ComponentMetaData.InputCollection[0];
            inputColumnInfos = new ColumnInfo[input.InputColumnCollection.Count];
            for (int i = 0; i < input.InputColumnCollection.Count; i++)
            {
                IDTSInputColumn100 column = input.InputColumnCollection[i];
                inputColumnInfos[i] = new ColumnInfo();

                inputColumnInfos[i].bufferColumnIndex = BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID);
                inputColumnInfos[i].columnDisposition = column.ErrorRowDisposition;

                inputColumnInfos[i].lineageID = column.LineageID;
                inputColumnInfos[i].dataType = column.DataType.ToString();

            }
            IDTSOutput100 output = ComponentMetaData.OutputCollection[0];
            outputColumnInfos = new ColumnInfo[output.OutputColumnCollection.Count];
            for (int j = 0; j < output.OutputColumnCollection.Count; j++)
            {
                IDTSOutputColumn100 column2 = output.OutputColumnCollection[j];
                outputColumnInfos[j] = new ColumnInfo();

                outputColumnInfos[j].bufferColumnIndex = BufferManager.FindColumnByLineageID(input.Buffer, column2.LineageID);
                outputColumnInfos[j].columnDisposition = column2.ErrorRowDisposition;

                outputColumnInfos[j].lineageID = column2.LineageID;
                outputColumnInfos[j].dataType = column2.DataType.ToString();


            }

            if ((ComponentMetaData.CustomPropertyCollection["NullValue"].Value != null) && (ComponentMetaData.CustomPropertyCollection["NullValue"].Value.ToString().Length > 0))
            {
                nullValue = (string) ComponentMetaData.CustomPropertyCollection["NullValue"].Value;
            }
        }
        #endregion PreExecute

        #region OnInputPathAttached
        public override void OnInputPathAttached(int inputID)
        {

        }
        #endregion OnInputPathAttached

        #region ProcessInput
        public override void ProcessInput(int inputID, PipelineBuffer buffer)
        {
            if (buffer == null)
            {
                throw new ArgumentNullException("buffer");
            }

            if (!buffer.EndOfRowset)
            {
                IDTSInput100 input = ComponentMetaData.InputCollection.GetObjectByID(inputID);

                int errorOutputID = -1;
                int errorOutputIndex = -1;
                int defaultOutputId = -1;

                GetErrorOutputInfo(ref errorOutputID, ref errorOutputIndex);

                defaultOutputId = errorOutputIndex == 0 ? ComponentMetaData.OutputCollection[1].ID : ComponentMetaData.OutputCollection[0].ID;

                while (buffer.NextRow())
                {
                    if (inputColumnInfos.Length == 0)
                    {
                        buffer.DirectRow(defaultOutputId);
                    }
                    else
                    {
                        var isError = false;
                        var inputByteBuffer = new byte[1000];
                        var bufferUsed = 0;
                        uint blobLength = 0;
                        var columnToProcessID = 0;

                        for (int i = 0; i < inputColumnInfos.Length; i++)
                        {
                            ColumnInfo info = inputColumnInfos[i];
                            columnToProcessID = info.bufferColumnIndex;

                            if (!buffer.IsNull(columnToProcessID))
                            {
                                switch (buffer.GetColumnInfo(columnToProcessID).DataType)
                                {
                                    case DataType.DT_BOOL:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetBoolean(columnToProcessID));
                                        break;
                                    case DataType.DT_IMAGE:
                                        blobLength = buffer.GetBlobLength(columnToProcessID);
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetBlobData(columnToProcessID, 0, (int)blobLength));
                                        break;
                                    case DataType.DT_BYTES:
                                        byte[] bytesFromBuffer = buffer.GetBytes(columnToProcessID);
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, bytesFromBuffer);
                                        break;
                                    case DataType.DT_CY:
                                    case DataType.DT_DECIMAL:
                                    case DataType.DT_NUMERIC:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetDecimal(columnToProcessID));
                                        break;
                                    //case DataType.DT_DBTIMESTAMPOFFSET:
                                    //    DateTimeOffset dateTimeOffset = buffer.GetDateTimeOffset(columnToProcessID);
                                    //    Utility.Append(ref inputByteBuffer, ref bufferUsed, dateTimeOffset);
                                    //    break;
                                    case DataType.DT_DBDATE:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetDate(columnToProcessID), millisecondHandling);
                                        break;
                                    case DataType.DT_DATE:
                                    case DataType.DT_DBTIMESTAMP:
                                    case DataType.DT_DBTIMESTAMP2:
                                    case DataType.DT_FILETIME:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetDateTime(columnToProcessID), millisecondHandling);
                                        break;
                                    case DataType.DT_DBTIME:
                                    case DataType.DT_DBTIME2:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetTime(columnToProcessID));
                                        break;
                                    case DataType.DT_GUID:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetGuid(columnToProcessID));
                                        break;
                                    case DataType.DT_I1:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetSByte(columnToProcessID));
                                        break;
                                    case DataType.DT_I2:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetInt16(columnToProcessID));
                                        break;
                                    case DataType.DT_I4:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetInt32(columnToProcessID));
                                        break;
                                    case DataType.DT_I8:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetInt64(columnToProcessID));
                                        break;
                                    case DataType.DT_STR:
                                    case DataType.DT_TEXT:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetString(columnToProcessID), Encoding.ASCII);
                                        break;
                                    case DataType.DT_NTEXT:
                                    case DataType.DT_WSTR:
                                        var wstr = buffer.GetString(columnToProcessID);
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetString(columnToProcessID), Encoding.Unicode);
                                        break;
                                    case DataType.DT_R4:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetSingle(columnToProcessID));
                                        break;
                                    case DataType.DT_R8:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetDouble(columnToProcessID));
                                        break;
                                    case DataType.DT_UI1:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetByte(columnToProcessID));
                                        break;
                                    case DataType.DT_UI2:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetUInt16(columnToProcessID));
                                        break;
                                    case DataType.DT_UI4:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetUInt32(columnToProcessID));
                                        break;
                                    case DataType.DT_UI8:
                                        Utility.Append(ref inputByteBuffer, ref bufferUsed, buffer.GetUInt64(columnToProcessID));
                                        break;
                                    case DataType.DT_EMPTY:
                                    case DataType.DT_NULL:
                                    default:
                                        break;
                                }
                            }
                            else if (!string.IsNullOrEmpty(nullValue))
                            {
                                Utility.Append(ref inputByteBuffer, ref bufferUsed, nullValue, Encoding.ASCII);
                            }
                        }

                        var iByteBuffer = bufferUsed;
                        var trimmedByteBuffer = new byte[bufferUsed];
                        Array.Copy(inputByteBuffer, trimmedByteBuffer, iByteBuffer);

                        var sha1HashDual = new SHA1CryptoServiceProvider();
                        var hash = BitConverter.ToString(sha1HashDual.ComputeHash(trimmedByteBuffer)).Replace("-", "");
                        buffer.SetString(outputColumnInfos[0].bufferColumnIndex, hash);

                        if (!isError)
                        {
                            buffer.DirectRow(defaultOutputId);
                        }
                    }
                }
            }
        }

        #endregion ProcessInput

        public override string DescribeRedirectedErrorCode(int iErrorCode)
        {

            if (iErrorCode == INVALID_CHARACTER_INDEX)
                return InvalidCharacterIndexmessage;
            return "";
        }


        #endregion Runtime
    }
}
