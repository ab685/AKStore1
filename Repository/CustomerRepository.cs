using AKStore.Entity;
using AKStore.AppContext;
using System;
using System.Web;
using System.Linq;
using Dapper;
using AKStore.Extension;
using System.Collections.Generic;
using AKStore.Models;

namespace AKStore.Repository
{
    public class CustomerRepository : BaseRepository<Customer>, ICustomerRepository
    {


        public Tuple<bool, string> UpsertCustomer(Customer customer)
        {
            DistributorRepository distributorRepository = new DistributorRepository();
            var DistributorId = distributorRepository.FirstDistributor().Id;
            // var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            var customerCount = 0;
            if (db.Customer.Where(x => x.DistributorId == DistributorId).Count() > 0)
            {
                customerCount = db.Customer.Where(x => x.DistributorId == DistributorId).Max(x => x.SerialNo);
            }

            customer.DistributorId = DistributorId;
            string message = string.Empty;
            bool success = false;
            if (customer.Id == 0)
            {
                customer.SerialNo = customerCount + 1;
                customer.InsertedDate = DateTime.Now;
                customer.InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                db.Customer.Add(customer);
                db.SaveChanges();
                message = "Customer added successfully";
                success = true;
            }
            else
            {
                var oldCustomer = db.Customer.Find(customer.Id);
                if (oldCustomer != null)
                {
                    oldCustomer.Id = customer.Id;
                    oldCustomer.StoreName = customer.StoreName;
                    oldCustomer.UpdatedDate = DateTime.Now;
                    oldCustomer.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    oldCustomer.DistributorId = customer.DistributorId;

                    //db.Customer.Update(oldCustomer);
                    db.SaveChanges();
                    message = "Customer updated successfully";
                    success = true;
                }
            }
            return new Tuple<bool, string>(success, message);
        }
        public Tuple<bool, string> DeleteCustomer(int customerId)
        {
            var message = string.Empty;
            var success = false;
            var p = new DynamicParameters();
            p.Add("@Id", customerId);
            p.Add("@TableName", "customer");
            var msg = CommonOperations.Query<string>("DeleteById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            if (msg == null)
            {
                success = true;
                message = "Customer deleted successfully.";
            }
            else
            {
                success = true;
                message = "Customer not found.";
            }
            return new Tuple<bool, string>(success, message);
        }

        public IEnumerable<Customer> GetCustomers(int distributorId)
        {
            var p = new DynamicParameters();
            p.Add("@distributorId", distributorId);
            var customers = CommonOperations.Query<Customer>("GetCustomers", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return customers;
        }

        public Customer GetCustomerById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@Id", id);
            var customer = CommonOperations.Query<Customer>("GetCustomerById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return customer;

        }

        public List<ProductModel> GetProductDataByCustomerId(int customerId, string search,string company,string category)
        {
            var p = new DynamicParameters();
            p.Add("@CustomerId", customerId);
            p.Add("@Search",string.IsNullOrEmpty(search) ?null :search);
            p.Add("@Company", string.IsNullOrEmpty(company) ? null : company);
            p.Add("@Category", string.IsNullOrEmpty(category) ? null : category);
            var products = CommonOperations.Query<ProductModel>("GetProductDataByUserId", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return products;
        }
        public List<OrderModels> GetOrdersByCustomerId(int customerId, DateTime? fromDate, DateTime? toDate, int orderStatusId)
        {
            var p = new DynamicParameters();
            p.Add("@CustomerId", customerId);
            p.Add("@FromDate", fromDate ?? DateTime.Now.AddDays(-30));
            p.Add("@ToDate", toDate ?? DateTime.Now);
            p.Add("@OrderStatusId", orderStatusId);
            var orders = CommonOperations.Query<OrderModels>("GetOrdersByCustomerId", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return orders;
        }

    }
}
