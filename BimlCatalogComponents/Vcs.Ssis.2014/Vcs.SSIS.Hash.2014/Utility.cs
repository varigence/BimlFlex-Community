using System;
using System.IO;
using System.Text;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;
using IDTSOutputColumn = Microsoft.SqlServer.Dts.Pipeline.Wrapper.IDTSOutputColumn100;

namespace Vcs.SSIS
{
    public static class Utility
    {
        #region Property Name Constants
        //// These are the constants for the Custom Properties used in this component.

        /// <summary>
        /// Stores the hash property name
        /// </summary>
        private const string ConstHashTypePropName = "HashType";

        /// <summary>
        /// Stores the input column's lineage id
        /// </summary>
        private const string ConstInputColumnLineagePropName = "InputColumnLineageIDs";

        /// <summary>
        /// Stores the thread name
        /// </summary>
        private const string ConstMultipleThreadPropName = "MultipleThreads";

        /// <summary>
        /// This is the name of the SSIS Property that holds the Safe Null Handling details.
        /// </summary>
        private const string ConstSafeNullHandlingPropName = "SafeNullHandling";

        /// <summary>
        /// This is the name of the SSIS Propery that holds the Millisecond handling details.
        /// </summary>
        private const string ConstMillsecondPropName = "IncludeMillsecond";
        #endregion

        /// <summary>
        /// Gets the hash property name
        /// </summary>
        public static string HashTypePropName
        {
            get
            {
                return ConstHashTypePropName;
            }
        }

        /// <summary>
        /// Gets the lineage property name
        /// </summary>
        public static string InputColumnLineagePropName
        {
            get
            {
                return ConstInputColumnLineagePropName;
            }
        }

        /// <summary>
        /// Gets the name of the thread
        /// </summary>
        public static string MultipleThreadPropName
        {
            get
            {
                return ConstMultipleThreadPropName;
            }
        }

        /// <summary>
        /// Gets the name of the Safe Null Handling Property.
        /// </summary>
        public static string SafeNullHandlingPropName
        {
            get
            {
                return ConstSafeNullHandlingPropName;
            }
        }


        public static string HandleMillisecondPropName
        {
            get
            {
                return ConstMillsecondPropName;
            }
        }

        #region Types to Byte Arrays
        /// <summary>
        /// Converts from bool to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(bool value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from decimal to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(decimal value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from DateTimeOffset to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <param name="millisecondHandling"></param>
        /// <returns>byte array</returns>
        private static byte[] ToArray(DateTimeOffset value, Boolean millisecondHandling)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(millisecondHandling
                        ? value.ToString("yyyy-MM-dd HH:mm:ss.fffffff zzz")
                        : value.ToString("u"));
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from DateTime to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(DateTime value, Boolean millisecondHandling)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(millisecondHandling
                        ? value.ToString("yyyy-MM-dd HH:mm:ss.fffffff")
                        : value.ToString("u"));
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from TimeSpan to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(TimeSpan value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value.ToString());
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from byte to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(byte value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from Guid to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(Guid value)
        {
            return value.ToByteArray();
        }

        /// <summary>
        /// Converts from int16 to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(short value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from Int32 to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(int value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from Int64 to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(long value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from Single to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(float value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from Double to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(double value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from UInt16 to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(ushort value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from UInt32 to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(uint value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from UInt64 to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(ulong value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        /// <summary>
        /// Converts from sbyte to a byte array.
        /// </summary>
        /// <param name="value">input value to convert to byte array</param>
        /// <returns>byte array</returns>
        public static byte[] ToArray(sbyte value)
        {
            using (MemoryStream stream = new MemoryStream())
            {
                using (BinaryWriter writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        #endregion

        #region Byte Array Appending

        /// <summary>
        /// Append bool To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, bool value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append DateTimeOffset To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        private static void Append(ref byte[] array, ref Int32 bufferUsed, System.DateTimeOffset value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value, true));
        }

        /// <summary>
        /// Append DateTime To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        /// <param name="millisecondHandling"></param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, DateTime value, Boolean millisecondHandling)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value, millisecondHandling));
        }

        /// <summary>
        /// Append Time To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, TimeSpan value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Guid To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, Guid value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append UInt64 To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, ulong value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Single To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, float value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Byte To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, byte value)
        {
            if (bufferUsed + 1 >= array.Length)
            {
                System.Array.Resize<byte>(ref array, array.Length + 1000);
            }

            array[bufferUsed++] = value;
        }

        /// <summary>
        /// Append Bytes To End Of Byte Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, byte[] value)
        {
            int valueLength = value.Length;
            int arrayLength = array.Length;

            if (bufferUsed + valueLength >= arrayLength)
            {
                if (valueLength > 1000)
                {
                    System.Array.Resize<byte>(ref array, arrayLength + valueLength + 1000);
                }
                else
                {
                    System.Array.Resize<byte>(ref array, arrayLength + 1000);
                }
            }

            System.Array.Copy(value, 0, array, bufferUsed, valueLength);
            bufferUsed += valueLength;
        }

        /// <summary>
        /// Append SByte Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, sbyte value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Short Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, short value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append UShort Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, ushort value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Integer Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, int value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Long Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, long value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append UInt Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, uint value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Double Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, double value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Decimal Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, decimal value)
        {
            Utility.Append(ref array, ref bufferUsed, Utility.ToArray(value));
        }

        /// <summary>
        /// Append Char Value Bytes To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        /// <param name="encoding">The encoding of the data</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, char value, Encoding encoding)
        {
            Utility.Append(ref array, ref bufferUsed, encoding.GetBytes(new char[] { value }));
        }

        /// <summary>
        /// Append String Bytes From Encoding To Array
        /// </summary>
        /// <param name="array">Original Value</param>
        /// <param name="bufferUsed"></param>
        /// <param name="value">Value To Append</param>
        /// <param name="encoding">Encoding To Use</param>
        public static void Append(ref byte[] array, ref Int32 bufferUsed, string value, System.Text.Encoding encoding)
        {
            Utility.Append(ref array, ref bufferUsed, encoding.GetBytes(value));
        }
        #endregion

        #region SetOutputColumnDataType
        /// <summary>
        /// Configures the output column to the correct data type and length.
        /// </summary>
        /// <param name="outputColumn">The column to configure</param>
        public static void SetOutputColumnDataType(IDTSOutputColumn outputColumn)
        {
            outputColumn.SetDataTypeProperties(DataType.DT_BYTES, 20, 0, 0, 0);
        }
        #endregion

        #region System Information
        /// <summary>
        /// Function to get the number of processor cores
        /// </summary>
        /// <returns>The number of cores</returns>
        public static int GetNumberOfProcessorCores()
        {
            try
            {
                Int64 processorMask = System.Diagnostics.Process.GetCurrentProcess().ProcessorAffinity.ToInt64();
                int numProcessors = (int)Math.Log(processorMask, 2) + 1;
                return Math.Max(1, numProcessors);
            }
            catch
            {
                return 1;
            }
        }
        #endregion
    }
}
