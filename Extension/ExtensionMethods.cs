
using System;
using System.Collections.Generic;
using System.Data;


using System.Dynamic;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Web;

namespace AKStore.Extension
{
	public static class ExtensionMethods
	{


		//public static string GetTableName<T>(this T t) where T : class
		//{
		//	var context = new HRMSContext();
		//	ObjectContext objectContext = ((IObjectContextAdapter)context).ObjectContext;

		//	return objectContext.GetTableName<T>();
		//}

		//public static string GetTableName<T>(this ObjectContext context) where T : class
		//{
		//	string sql = context.CreateObjectSet<T>().ToTraceString();
		//	Regex regex = new Regex("FROM (?<table>.*) AS");
		//	Match match = regex.Match(sql);

		//	string table = match.Groups["table"].Value;
		//	return table;
		//}

		public static List<dynamic> ToDynamicList(this DataTable dt)
		{
			var list = new List<dynamic>();
			foreach (DataRow row in dt.Rows)
			{
				dynamic dyn = new ExpandoObject();
				list.Add(dyn);
				foreach (DataColumn column in dt.Columns)
				{
					var dic = (IDictionary<string, object>)dyn;
					dic[column.ColumnName] = row[column];
				}
			}
			return list;
		}

		private static List<T> ConvertDataTable<T>(this DataTable dt)
		{
			List<T> data = new List<T>();
			foreach (DataRow row in dt.Rows)
			{
				T item = GetItem<T>(row);
				data.Add(item);
			}
			return data;
		}
		private static T GetItem<T>(this DataRow dr)
		{
			Type temp = typeof(T);
			T obj = Activator.CreateInstance<T>();

			foreach (DataColumn column in dr.Table.Columns)
			{
				foreach (PropertyInfo pro in temp.GetProperties())
				{
					if (pro.Name == column.ColumnName)
						pro.SetValue(obj, dr[column.ColumnName], null);
					else
						continue;
				}
			}
			return obj;
		}
		public static IEnumerable<T> CastList<T>(this IEnumerable<object> entity) where T : class
		{
			var ret = entity
				.Select(e => e as T)
				.ToList();

			return ret;
		}
		public static bool IsAjaxRequest(this HttpRequest request)
		{
			if (request == null)
				throw new ArgumentNullException(nameof(request));

			if (request.Headers != null)
				return !string.IsNullOrEmpty(request.Headers["X-Requested-With"]) &&
					string.Equals(
						request.Headers["X-Requested-With"],
						"XmlHttpRequest",
						StringComparison.OrdinalIgnoreCase);

			return false;
		}
	}
}