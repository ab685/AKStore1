using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AKStore.Entity;
using AKStore.AppContext;
using AKStore.Models;
using System.Web;
using Dapper;
using AKStore.Extension;
using System.Data;

namespace AKStore.Repository
{
    public class OrderRepository : BaseRepository<OrderMaster>, IOrderRepository
    {
        public OrderRepository() : base()
        {

        }


        public IEnumerable<OrderModels> GetOrderData(int retailerId, DateTime? fromDate, DateTime? toDate)
        {

            var p = new DynamicParameters();
            p.Add("@retailerId", retailerId);
            p.Add("@fromDate", fromDate);
            p.Add("@toDate", toDate);
            var orderModels = CommonOperations.Query<OrderModels>("GetOrdersData", p, commandType: CommandType.StoredProcedure).ToList();
            return orderModels;
        }
        public Tuple<bool, string> UpsertOrder(OrderMaster orderMaster)
        {

            string message = string.Empty;
            bool success = false;
            if (orderMaster.Id == 0)
            {
                message = "Sale added successfully";
                success = true;

                orderMaster.InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                orderMaster.InsertedDate = DateTime.Now;
            }
            else
            {
                orderMaster.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                orderMaster.UpdatedDate = DateTime.Now;
                message = "Sale updated successfully";
                success = true;
            }
            var p = new DynamicParameters();
            p.Add("@Id", orderMaster.Id);
            p.Add("@DistributorId", orderMaster.DistributorId);
            p.Add("@OrderStatusId", orderMaster.OrderStatusId);
            p.Add("@ProductId", orderMaster.ProductId);
            p.Add("@CustomerId", orderMaster.CustomerId);
            p.Add("@Quantity", orderMaster.Quantity);
            p.Add("@Price", orderMaster.Price);
            p.Add("@Total", orderMaster.Total);
            p.Add("@OrderDate", orderMaster.OrderDate);
            p.Add("@IsActive", orderMaster.IsActive);
            p.Add("@InsertedDate", orderMaster.InsertedDate);
            p.Add("@UpdatedDate", orderMaster.UpdatedDate);
            p.Add("@InsertedByUserId", orderMaster.InsertedByUserId);
            p.Add("@UpdatedByUserId", orderMaster.UpdatedByUserId);
            var msg = CommonOperations.Query<string>("UpsertOrder", p, commandType: CommandType.StoredProcedure).FirstOrDefault();
            if (msg != null)
            {
                message = "Some thing went wrong";
                success = false;
            }


            return new Tuple<bool, string>(success, message);
        }

        public Tuple<bool, string> DeleteOrder(int orderId)
        {
            var message = string.Empty;
            var success = false;
            var p = new DynamicParameters();
            p.Add("@Id", orderId);
            p.Add("@TableName", "order");
            var msg = CommonOperations.Query<string>("DeleteById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            if (msg == null)
            {
                message = "Sale deleted successfully.";
                success = true;
            }
            else
            {
                message = "Sale not found.";
                success = true;
            }



            return new Tuple<bool, string>(success, message);
        }

        public Dictionary<string, decimal?> ChangeCustomerDetails(int customerId, int shift)
        {
            decimal? price = 0, quantity = 0, total = 0;

            var customer = db.Customer.Find(customerId);
            if (customer != null)
            {


                total = price * quantity;

                Dictionary<string, decimal?> keyValuePairs = new Dictionary<string, decimal?>();
                keyValuePairs.Add("price", price);
                keyValuePairs.Add("quantity", quantity);
                keyValuePairs.Add("total", total);
                return keyValuePairs;
            }
            else
            {
                return new Dictionary<string, decimal?>();
            }
        }

        public List<OrderModels> GetDailyOrdersData(int retailerId, int routeId, int shift, DateTime saleDate)
        {
            var p = new DynamicParameters();
            p.Add("@RetailerId", retailerId);
            p.Add("@RouteId", routeId);
            p.Add("@Shift", shift);
            p.Add("@SaleDate", saleDate);
            var orderModels = CommonOperations.Query<OrderModels>("GetDailyOrderData", p, commandType: System.Data.CommandType.StoredProcedure).ToList();

            return orderModels;
        }

        public DataSet CustomerDetailsReport(DateTime fromDate, DateTime toDate, int customerId, int retailerId)
        {
            var p = new DynamicParameters();
            p.Add("@CustomerId", customerId);
            p.Add("@FromDate", fromDate);
            p.Add("@ToDate", toDate);
            p.Add("@RetailerId", retailerId);
            var ds = CommonOperations.QuerySpecial("GetCustomerDetailsRport", p, System.Data.CommandType.StoredProcedure);
            return ds;
        }

        public OrderMaster GetOrderById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            var orderMaster = CommonOperations.Query<OrderMaster>("GetOrderById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return orderMaster;
        }
        public int UpdateOrderStatusById(List<int> ids, int orderStatusId)
        {

            var p = new DynamicParameters();
            DataTable dt = new DataTable();
            dt.Columns.Add("Item", typeof(Int32));
            ids.ForEach(x => dt.Rows.Add(x));


            p.Add("@OrderStatusId", orderStatusId);
            p.Add("@UpdatedByUserId", Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]));
            p.Add("@ProductIds",dt.AsTableValuedParameter("IntList"));
            var res = 0;
            using (var con = CommonOperations.GetConnection())
            {
                res = con.Query<int>("UpdateOrderStatusById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            }
            return res;
        }

        public List<DistributorOrderDataModel> GetOrderDataForDistributor(DistributorOrderModel distributorOrderModel)
        {
            var p = new DynamicParameters();
            p.Add("@OrderStatusId", distributorOrderModel.OrderStatusId);
            p.Add("@DistributorId", distributorOrderModel.DistributorId);
            p.Add("@CustomerId", distributorOrderModel.CustomerId);
            p.Add("@FromDate", distributorOrderModel.FromDate ?? DateTime.Now.AddDays(-2));
            p.Add("@ToDate", distributorOrderModel.ToDate ?? DateTime.Now);
            var res = CommonOperations.Query<DistributorOrderDataModel>("GetDistributorOrders", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return res;
        }
    }
}
