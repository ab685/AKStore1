using Dapper;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Web.Script.Serialization;

namespace AKStore.Extension
{
    public class CommonOperations
    {
        public static SqlConnection GetConnection()
        {
            //if (string.IsNullOrWhiteSpace(connectionString))
            //{
            //	return new SqlConnection("");
            //}
            var con = System.Configuration.ConfigurationManager.ConnectionStrings["AKStoreContext"].ConnectionString;
            return new SqlConnection(con);
        }
        public static int Execute(string query)
        {
            using (var conn = GetConnection())
            {
                return conn.Execute(query);
            }

        }
        //public static BaseRepository<T, C> GetRepository<T, C>()
        //	where T : EntityBase, new()
        //	where C : DbContext, new()
        //{
        //	return new BaseRepository<T, C>();
        //}

        public static DataSet QuerySpecial(string query, object args = null, CommandType cmdType = CommandType.Text, string connectionString = "", IEnumerable<string> resultTableNames = null)
        {
            DataSet ds = new DataSet();
            List<string> dtArr = new List<string>();

            List<string> tablesToRemove = new List<string>();
            var ym = 0;
            using (var conn = GetConnection())
            using (var reader = conn.ExecuteReader(query, param: PrepareDynamicParameters(args), commandType: cmdType))
                while (!reader.IsClosed)
                    ds.Tables.Add().Load(reader);

            if (resultTableNames != null)
                foreach (var table in ds.Tables)
                {
                    if (ym < resultTableNames.Count())
                    {
                        ds.Tables[ym].TableName = resultTableNames.ToArray()[ym];
                        ym++;
                    }
                }
            return ds;
        }

        public static DataSet QuerySpecial(string query, List<SqlParameter> args = null, CommandType cmdType = CommandType.Text, string connectionString = "")
        {
            DataSet ds = new DataSet();

            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(query, conn))
            {
                cmd.CommandType = cmdType;
                if (args != null && args.Count > 0)
                    cmd.Parameters.AddRange(args.ToArray());
                if (conn.State != ConnectionState.Open)
                    conn.Open();
                using (var reader = cmd.ExecuteReader())
                    while (!reader.IsClosed)
                        ds.Tables.Add().Load(reader);
                //ds.Load(reader, LoadOption.OverwriteChanges);

                //using (SqlDataAdapter adp = new SqlDataAdapter(cmd))
                //    adp.Fill(ds);
            }
            return ds;
        }
        //public static IEnumerable<T> Query<T>(string query, object args = null, string connectionString = "")
        //{
        //    using (var conn = GetConnection(connectionString))
        //        return conn.Query<T>(query, args).ToList();


        //}
        public static IEnumerable<T> Query<T>(string query, object args = null, string connectionString = "", CommandType commandType = CommandType.Text)
        {
            using (var conn = GetConnection())
                return conn.Query<T>(query, param: PrepareDynamicParameters(args), commandType: commandType).ToList();
        }

        public static int ExecuteSpecial(string query, object args = null, string connectionString = "", CommandType commandType = CommandType.Text)
        {
            using (var conn = GetConnection())
                return conn.Execute(query, param: PrepareDynamicParameters(args), commandType: commandType);

            //if (commandType == CommandType.StoredProcedure)
            //{
            //    if (parameters.IsAny())
            //        using (var conn = GetConnection(connectionString))
            //            return conn.Query<T>(query, PrepareDynamicParameters(parameters), commandType: CommandType.StoredProcedure);
            //    else
            //        using (var conn = GetConnection(connectionString))
            //            return conn.Query<T>(query, commandType: CommandType.StoredProcedure);
            //}

        }
        static void PropertySetLooping(object p, string propName, object value)
        {
            Type t = p.GetType();
            foreach (PropertyInfo info in t.GetProperties())
            {
                if (info.Name == propName && info.CanWrite)
                {
                    info.SetValue(p, value, null);
                }
            }
        }
        public static T QueryMultiple<T>(string query, T res = null, IEnumerable<string> propertyNames = null, object args = null, string connectionString = "", CommandType commandType = CommandType.Text)
            where T : class
        {
            List<PropertyInfo> propertyInfo = new List<PropertyInfo>(); ;
            if (res == null)
                res = (T)Activator.CreateInstance(typeof(T));

            using (var conn = GetConnection())
            using (var result = conn.QueryMultiple(query, param: PrepareDynamicParameters(args), commandType: commandType))
            {
                if (!propertyNames.Any())
                    propertyInfo = typeof(T).GetProperties().ToList();
                else
                {
                    propertyNames.ToList().ForEach(p =>
                    {
                        //if (typeof(T).HasProperty(p))
                        propertyInfo.Add(typeof(T).GetProperty(p));
                    });
                }
                foreach (PropertyInfo prop in propertyInfo)
                {
                    if (!result.IsConsumed)
                    {
                        if (typeof(IEnumerable).IsAssignableFrom(prop.PropertyType))
                        {
                            var typ = prop.PropertyType.GetGenericArguments().Single();
                            var castListMethod = typeof(ExtensionMethods).GetMethod("CastList").MakeGenericMethod(new[] { typ });
                            var ss = result.Read(typ).ToList();
                            var sddf = castListMethod.Invoke(null, new[] { ss });
                            //Convert.ChangeType(ss, typ);
                            prop.SetValue(res, sddf, null);
                        }
                        else
                        {
                            var typ = prop.PropertyType;
                            var ss = result.Read(typ).SingleOrDefault();
                            prop.SetValue(res, ss, null);
                        }
                    }

                }
            }
            return res;
        }




        public static DynamicParameters PrepareDynamicParameters(object arg)
        {
            int i = 2;
            object key = null;
            object value = null;
            DynamicParameters dp = null;

            if (arg is DynamicParameters)
                return (DynamicParameters)arg;

            if (arg is IEnumerable)
            {
                var h = arg as IEnumerable;

                if (h != null)
                {
                    dp = new DynamicParameters();
                    var enm = h.GetEnumerator();
                    while (enm.MoveNext())
                    {
                        if (i % 2 == 0)
                        {
                            key = enm.Current;
                            i++;
                            continue;
                        }
                        else
                        {
                            value = enm.Current;
                            if (value != null)
                            {
                                if (value is IEnumerable && !value.GetType().FullName.Equals("System.String"))
                                {
                                    Type aa = null;
                                    if (value.GetType().IsGenericType)
                                        aa = value.GetType().GetGenericArguments()[0];
                                    else
                                        aa = value.GetType().GetElementType();

                                    var dt = PrepareDatatable(value as IEnumerable);
                                    string dbtype = string.Empty;
                                    if (aa.Name.Equals("Int32"))
                                        dbtype = "IntList";
                                    if (aa.Name.Equals("String"))
                                        dbtype = "StringList";
                                    dp.Add(key.ToString(), dt.AsTableValuedParameter(dbtype));
                                }
                                else if (value.GetType().FullName.Equals("System.Data.DataTable"))
                                {
                                    var dt = (DataTable)value;
                                    var tableName = dt.TableName;
                                    dp.Add(key.ToString(), dt.AsTableValuedParameter(tableName));
                                }
                                else
                                    dp.Add(key.ToString(), value);
                            }
                        }
                        i++;
                    }
                }
            }

            return dp;
        }
        public static DataTable PrepareDatatable(IEnumerable val)
        {
            DataTable dt = new DataTable();
            Type aa = null;
            if (val.GetType().IsGenericType)
                aa = val.GetType().GetGenericArguments()[0];
            else
                aa = val.GetType().GetElementType();
            dt.Columns.Add("Item", aa);
            foreach (var item in val)
            {
                dt.Rows.Add(item);
            }
            return dt;
        }
        //public static void SqlBulkCopy<T>(IEnumerable<T> t, string destinationTableName = "") where T : EntityBase, new()
        //{
        //	var options = SqlBulkCopyOptions.KeepNulls
        //				| SqlBulkCopyOptions.FireTriggers
        //				| SqlBulkCopyOptions.CheckConstraints
        //				| SqlBulkCopyOptions.UseInternalTransaction;
        //	using (SqlBulkCopy bc = new SqlBulkCopy(TaskApiSettings.CrmTaskContext, options))
        //	{
        //		if (string.IsNullOrWhiteSpace(destinationTableName))
        //			bc.DestinationTableName = t.FirstOrDefault().GetType().Name;
        //		else
        //			bc.DestinationTableName = destinationTableName;

        //		#region Using Datatable
        //		var dt = t.ToDataTableDataReader();
        //		foreach (DataColumn col in dt.Columns)
        //		{
        //			bc.ColumnMappings.Add(col.ColumnName, col.ColumnName);
        //		}
        //		//bc.WriteToServer(dt);
        //		#endregion
        //		//if (con.State != ConnectionState.Open)
        //		//{
        //		//    con.Open();
        //		//}
        //		//bc.WriteToServer(t.AsDataReader());
        //		bc.WriteToServer(dt);
        //	}
        //}

        //public static void SqlBulkCopyWithoutMapping<T>(IEnumerable<T> t) where T : EntityBase, new()
        //{
        //	var options = SqlBulkCopyOptions.KeepNulls
        //				| SqlBulkCopyOptions.FireTriggers
        //				| SqlBulkCopyOptions.CheckConstraints
        //				| SqlBulkCopyOptions.UseInternalTransaction;
        //	using (SqlBulkCopy bc = new SqlBulkCopy(TaskApiSettings.CrmTaskContext, options))
        //	{
        //		bc.DestinationTableName = t.FirstOrDefault().GetType().Name;
        //		#region Using Datatable
        //		var dt = t.ToDataTableDataReader();
        //		#endregion
        //		bc.WriteToServer(dt);
        //	}
        //}

        //public static void Truncate<T>(string connectionString = "") where T : EntityBase, new()
        //{
        //	Execute("TRUNCATE TABLE " + typeof(T).Name, connectionString);
        //}

        public static object DataSetToJSON(DataSet ds)
        {
            ArrayList root = new ArrayList();
            List<Dictionary<string, object>> table;
            Dictionary<string, object> data;

            foreach (DataTable dt in ds.Tables)
            {
                table = new List<Dictionary<string, object>>();
                foreach (DataRow dr in dt.Rows)
                {
                    data = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        data.Add(col.ColumnName, dr[col]);
                    }
                    table.Add(data);
                }
                root.Add(table);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(root);
        }
    }
}

