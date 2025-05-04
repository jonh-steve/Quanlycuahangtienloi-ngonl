using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace QuanLyCuaHangTienLoi.Db
{
    public abstract class BaseRepository
    {
        // Phương thức thực thi stored procedure với tham số và trả về DataTable
        protected DataTable ExecuteStoredProcedure(string storedProcName, List<SqlParameter> parameters = null)
        {
            try
            {
                SqlParameter[] paramArray = parameters?.ToArray();
                return ConnectionManager.ExecuteQuery(storedProcName, CommandType.StoredProcedure, paramArray);
            }
            catch (Exception ex)
            {
                Logger.LogException(ex, $"Lỗi khi thực thi stored procedure: {storedProcName}");
                throw;
            }
        }

        // Phương thức thực thi stored procedure không trả về dữ liệu
        protected int ExecuteNonQueryStoredProcedure(string storedProcName, List<SqlParameter> parameters = null)
        {
            try
            {
                SqlParameter[] paramArray = parameters?.ToArray();
                return ConnectionManager.ExecuteNonQuery(storedProcName, CommandType.StoredProcedure, paramArray);
            }
            catch (Exception ex)
            {
                Logger.LogException(ex, $"Lỗi khi thực thi stored procedure: {storedProcName}");
                throw;
            }
        }

        // Phương thức thực thi stored procedure và trả về giá trị đầu tiên
        protected object ExecuteScalarStoredProcedure(string storedProcName, List<SqlParameter> parameters = null)
        {
            try
            {
                SqlParameter[] paramArray = parameters?.ToArray();
                return ConnectionManager.ExecuteScalar(storedProcName, CommandType.StoredProcedure, paramArray);
            }
            catch (Exception ex)
            {
                Logger.LogException(ex, $"Lỗi khi thực thi stored procedure: {storedProcName}");
                throw;
            }
        }

        // Phương thức tạo parameter
        protected SqlParameter CreateParameter(string paramName, object value, SqlDbType dbType)
        {
            return new SqlParameter
            {
                ParameterName = paramName,
                Value = value ?? DBNull.Value,
                SqlDbType = dbType
            };
        }

        // Phương thức tạo parameter với kích thước
        protected SqlParameter CreateParameter(string paramName, object value, SqlDbType dbType, int size)
        {
            SqlParameter param = CreateParameter(paramName, value, dbType);
            param.Size = size;
            return param;
        }

        // Phương thức map dữ liệu từ SqlDataReader sang đối tượng
        protected T MapToObject<T>(SqlDataReader reader) where T : new()
        {
            T obj = new T();
            Type type = typeof(T);

            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (!reader.IsDBNull(i))
                {
                    string columnName = reader.GetName(i);
                    var property = type.GetProperty(columnName);

                    if (property != null && property.CanWrite)
                    {
                        property.SetValue(obj, Convert.ChangeType(reader.GetValue(i), property.PropertyType));
                    }
                }
            }

            return obj;
        }
    }
}