using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AKStore.Entity;
using AKStore.Models;

namespace AKStore.Repository
{
    public interface ICustomerRepository : IBaseRepository<Customer>
    {
        Tuple<bool, string> UpsertCustomer(Customer customer);
        Tuple<bool, string> DeleteCustomer(int customerId);
        IEnumerable<Customer> GetCustomers(int distributorId);
        Customer GetCustomerById(int id);
        List<ProductModel> GetProductDataByCustomerId(int customerId,string search,string company, string category);
        List<OrderModels> GetOrdersByCustomerId(int customerId, DateTime? fromDate, DateTime? toDate, int orderStatusId);
    }
}
