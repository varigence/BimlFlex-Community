using System;
using System.IO;
using System.Text;
using Microsoft.SqlServer.Dts.Runtime.Wrapper;
using IDTSOutputColumn = Microsoft.SqlServer.Dts.Pipeline.Wrapper.IDTSOutputColumn100;

namespace Varigence.Ssis
{
    public static class Utility
    {
        #region Property Name Constants
        private const string ConstHashTypePropName = "HashType";
        private const string ConstInputColumnLineagePropName = "InputColumnLineageIDs";
        private const string ConstMultipleThreadPropName = "MultipleThreads";
        private const string ConstSafeNullHandlingPropName = "SafeNullHandling";
        private const string ConstMillsecondPropName = "IncludeMillsecond";
        #endregion Property Name Constants

        public static string HashTypePropName => ConstHashTypePropName;

        public static string InputColumnLineagePropName => ConstInputColumnLineagePropName;

        public static string MultipleThreadPropName => ConstMultipleThreadPropName;

        public static string SafeNullHandlingPropName => ConstSafeNullHandlingPropName;

        public static string HandleMillisecondPropName => ConstMillsecondPropName;

        #region Types to Byte Arrays

        public static byte[] ToArray(bool value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(decimal value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        private static byte[] ToArray(DateTimeOffset value, bool millisecondHandling)
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

        public static byte[] ToArray(DateTime value, bool millisecondHandling)
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

        public static byte[] ToArray(TimeSpan value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value.ToString());
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(byte value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(Guid value)
        {
            return value.ToByteArray();
        }

        public static byte[] ToArray(short value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(int value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(long value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(float value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(double value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(ushort value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(uint value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(ulong value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        public static byte[] ToArray(sbyte value)
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new BinaryWriter(stream))
                {
                    writer.Write(value);
                    return stream.ToArray();
                }
            }
        }

        #endregion Types to Byte Arrays

        #region Byte Array Appending

        public static void Append(ref byte[] array, ref int bufferUsed, bool value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        private static void Append(ref byte[] array, ref int bufferUsed, System.DateTimeOffset value)
        {
            Append(ref array, ref bufferUsed, ToArray(value, true));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, DateTime value, bool millisecondHandling)
        {
            Append(ref array, ref bufferUsed, ToArray(value, millisecondHandling));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, TimeSpan value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, Guid value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, ulong value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, float value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, byte value)
        {
            if (bufferUsed + 1 >= array.Length)
            {
                System.Array.Resize<byte>(ref array, array.Length + 1000);
            }

            array[bufferUsed++] = value;
        }

        public static void Append(ref byte[] array, ref int bufferUsed, byte[] value)
        {
            var valueLength = value.Length;
            var arrayLength = array.Length;

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

        public static void Append(ref byte[] array, ref int bufferUsed, sbyte value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, short value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, ushort value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, int value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, long value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, uint value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, double value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, decimal value)
        {
            Append(ref array, ref bufferUsed, ToArray(value));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, char value, Encoding encoding)
        {
            Append(ref array, ref bufferUsed, encoding.GetBytes(new char[] { value }));
        }

        public static void Append(ref byte[] array, ref int bufferUsed, string value, System.Text.Encoding encoding)
        {
            Append(ref array, ref bufferUsed, encoding.GetBytes(value));
        }
        #endregion Byte Array Appending

        #region SetOutputColumnDataType
        public static void SetOutputColumnDataType(IDTSOutputColumn outputColumn)
        {
            outputColumn.SetDataTypeProperties(DataType.DT_BYTES, 20, 0, 0, 0);
        }
        #endregion SetOutputColumnDataType

        #region System Information
        public static int GetNumberOfProcessorCores()
        {
            try
            {
                var processorMask = System.Diagnostics.Process.GetCurrentProcess().ProcessorAffinity.ToInt64();
                var numProcessors = (int)Math.Log(processorMask, 2) + 1;
                return Math.Max(1, numProcessors);
            }
            catch
            {
                return 1;
            }
        }
        #endregion System Information
    }
}
