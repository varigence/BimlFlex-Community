using System;
using System.Linq;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;
using Microsoft.SqlServer.Dts.Pipeline.Wrapper;
using Microsoft.SqlServer.Dts.Pipeline;
namespace Varigence.Ssis
{
    [DtsPipelineComponent
    (DisplayName = "Biml Error Description",
     Description = "Converts Error Column into Description",
     ComponentType = ComponentType.Transform,
     IconResource = "Varigence.Ssis.Icons.ErrorDescription.ico")
    ]
    public class ErrorDescription : PipelineComponent
    {
        private int[] _inputBufferColumnIndex;
        private int[] _outputBufferColumnIndex;
        private string _maskedData;
        #region Design Time Methods

        public override void OnInputPathAttached(int inputID)
        {
        }

        public override void ProvideComponentProperties()
        {
            // Set component information
            ComponentMetaData.Name = "Error Description";
            ComponentMetaData.Description = "A SSIS Data Flow Transformation Component To Provide Error column Name from ErrorColum column";
            ComponentMetaData.ContactInfo = "";

            // Reset the component
            RemoveAllInputsOutputsAndCustomProperties();

            //Add input objects
            var input = ComponentMetaData.InputCollection.New();
            input.Name = "ErrorInput";
            input.Dangling = false;
            input.Description = "This is for Initialize component.";


            var input2 = ComponentMetaData.InputCollection.New();
            input2.Name = "SuccessInput";
            input2.Dangling = false;
            input2.Description = "This is for Initialize component.";

            // Add output objects
            var output = ComponentMetaData.OutputCollection.New();
            output.Name = "ErrorOutput";
            output.Description = "Contains Error columns. Gets set automatically. Extra One Column that is ErrorColumnName Get from this.";
            output.SynchronousInputID = input.ID; //Synchronous transformation!

            var outputcol1 = output.OutputColumnCollection.New();
            outputcol1.Name = "ErrorColumnName";
            outputcol1.Description = "Error Column Name ";
            outputcol1.SetDataTypeProperties(DataType.DT_STR, 50, 0, 0, 1252);

            var outputcol2 = output.OutputColumnCollection.New();
            outputcol2.Name = "ErrorDescription";
            outputcol2.Description = "Error Description ";
            outputcol2.SetDataTypeProperties(DataType.DT_STR, 1000, 0, 0, 1252);

            var outputcol3 = output.OutputColumnCollection.New();
            outputcol3.Name = "ErrorColumnValue";
            outputcol3.Description = "Error Column Value ";
            outputcol3.SetDataTypeProperties(DataType.DT_STR, 4000, 0, 0, 1252);

        }

        public override DTSValidationStatus Validate()
        {
            if (ComponentMetaData.InputCollection.Count == 2 && ComponentMetaData.OutputCollection.Count == 1)
            {
                var input = ComponentMetaData.InputCollection[1];
                var output2 = ComponentMetaData.OutputCollection.New();
                output2.Name = "SuccessOutput";
                output2.Description = "Contains columns. Gets set automatically.";
                output2.SynchronousInputID = input.ID; //Synchronous transformation!
            }

            return DTSValidationStatus.VS_ISVALID;
        }

        // Covers VSNEEDSNEWMETADATA from Validate()
        public override void ReinitializeMetaData()
        {
            // clean-up 
            if (!ComponentMetaData.AreInputColumnsValid)
            {
                ComponentMetaData.RemoveInvalidInputColumns();
            }

            base.ReinitializeMetaData();
        }

        // Disallow adding output
        public override IDTSOutputColumn100 InsertOutputColumnAt(int outputID, int outputColumnIndex, string name, string description)
        {
            bool cancel;
            ComponentMetaData.FireError(0, ComponentMetaData.Name, "Output columns cannot be added to " + ComponentMetaData.Name, "", 0, out cancel);

            throw new Exception("Output columns cannot be added to " + ComponentMetaData.Name, null);
        }

        #endregion Design Time Methods

        #region Run Time Methods

        public override void PreExecute()
        {

            Int16 i = 0;
            var input = ComponentMetaData.InputCollection[i];
            _inputBufferColumnIndex = new int[input.InputColumnCollection.Count];


            for (var x = 0; x < input.InputColumnCollection.Count; x++)
            {
                var column = input.InputColumnCollection[x];
                if (column.Name == "ErrorColumn")
                {
                    _inputBufferColumnIndex[0] = BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID);
                }
                if (column.Name == "ErrorCode")
                {
                    _inputBufferColumnIndex[1] = BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID);
                }
            }

            var output = ComponentMetaData.OutputCollection[i];
            _outputBufferColumnIndex = new int[output.OutputColumnCollection.Count];

            for (var x = 0; x < output.OutputColumnCollection.Count; x++)
            {
                var outcol = output.OutputColumnCollection[x];

                // A synchronous output does not appear in output buffer, but in input buffer
                _outputBufferColumnIndex[x] = BufferManager.FindColumnByLineageID(input.Buffer, outcol.LineageID);
            }
            var input1 = ComponentMetaData.InputCollection[1];

            _maskedData = input1.InputColumnCollection.Count.ToString();
        }

        // The actual data masking 
        public override void ProcessInput(int inputID, PipelineBuffer buffer)
        {
            var input = ComponentMetaData.InputCollection.GetObjectByID(inputID);

            if (input.Name != ComponentMetaData.InputCollection[0].Name) return;
            if (buffer.EndOfRowset) return;
            while (buffer.NextRow())
            {
                if (buffer.IsNull(0)) continue;
                var errorColumnName = MaskData(buffer.GetInt32(_inputBufferColumnIndex[0]));
                var errorColumnValue = "";
                //var errorConversion = "";

                for (var i = 0; i < input.InputColumnCollection.Count; i++)
                {
                    var column = input.InputColumnCollection[i];
                    if (!column.Name.EndsWith("__TGT__" + errorColumnName)) continue;
                    var bufferColumnIndex = BufferManager.FindColumnByLineageID(input.Buffer, column.LineageID);
                    errorColumnValue = !buffer.IsNull(bufferColumnIndex) ? buffer[bufferColumnIndex].ToString() : "";
                    //errorConversion = MaskDatatype(column.DataType.ToString(), column.Length.ToString(), column.Precision.ToString(), column.Scale.ToString());
                }
                
                buffer.SetString(_outputBufferColumnIndex[0], MaskData(buffer.GetInt32(_inputBufferColumnIndex[0])));
                buffer.SetString(_outputBufferColumnIndex[1], ComponentMetaData.GetErrorDescription(buffer.GetInt32(_inputBufferColumnIndex[1])));
                if (string.IsNullOrEmpty(errorColumnValue)) continue;
                buffer.SetString(_outputBufferColumnIndex[2], errorColumnValue);
                //errorConversion = MaskConversion(buffer.GetInt32(_inputBufferColumnIndex[0])) + " to " + errorConversion;
                //buffer.SetString(_outputBufferColumnIndex[3], errorConversion);
            }
        }

        #endregion Run Time Methods

        #region Data ErrorColumnName

        // Provides a basic data masking with scrambling column content
        public string MaskData(int lineage)
        {
            _maskedData = "";
            var input = ComponentMetaData.InputCollection[1];
            var column1 = input.InputColumnCollection.GetInputColumnByLineageID(lineage);
            _maskedData = "" + column1.Name + "";
            return _maskedData;
        }

        // Provides a basic data masking with scrambling column content
        public string MaskConversion(int lineage)
        {
            _maskedData = "";
            var input = ComponentMetaData.InputCollection[1];
            var column1 = input.InputColumnCollection.GetInputColumnByLineageID(lineage);
            _maskedData = "" + MaskDatatype(column1.DataType.ToString(), column1.Length.ToString(), column1.Precision.ToString(), column1.Scale.ToString()) + "";
            return _maskedData;
        }


        public string MaskDatatype(string datatype, string length, string precision, string scale)
        {
            var bimlDatatype = datatype;

            switch (datatype)
            {
                case "Decimal":
                    bimlDatatype = datatype + "(" + precision + ", " + scale + ")";
                    break;
                case "VarNumeric":
                case "Binary":
                case "String":
                case "StringFixedLength":
                case "AnsiString":
                case "AnsiStringFixedLength":
                    bimlDatatype = datatype + "(" + length + ")";
                    break;
            }

            return bimlDatatype;
        }

        #endregion Data ErrorColumnName

        

    }
}
