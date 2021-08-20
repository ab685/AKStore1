using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AKStore.Models;
using PagedList;

namespace AKStore.Services
{
    public interface ICustomerService
    {
        IEnumerable<CustomerModel> GetCustomerData(int distributorId);
        Tuple<bool, string> UpsertCustomer(CustomerModel customerModel);
        Tuple<bool, string> DeleteCustomer(int customerId);
        CustomerModel GetCustomerDataById(int id);
        IPagedList<ProductModel> GetProductDataByCustomerId(int customerId,string search,string company, string category, int? page);
        List<OrderModels> GetOrdersByCustomerId(int customerId, DateTime ?fromDate, DateTime? toDate, int orderStatusId);
    }
}
