using AKStore.Models;
using System;
using System.Collections.Generic;
using System.Data;

namespace AKStore.Services
{
    public interface IOrderService
    {
        IEnumerable<OrderModels> GetOrderData(int retailerId, DateTime? fromDate, DateTime? toDate);
        Tuple<bool, string> UpsertOrder(CustomerProductModel orderModels);
        Tuple<bool, string> DeleteOrder(int orderId);
        Dictionary<string, decimal?> ChangeCustomerDetails(int customerId, int shift);
        OrderModels GetOrderById(int id);

        List<OrderModels> GetDailyOrdersData(int retailerId, int routeId, int shift, DateTime saleDate);
        DataSet CustomerDetailsReport(DateTime fromDate, DateTime toDate, int customerId, int retailerId);
        List<DistributorOrderDataModel> GetOrderDataForDistributor(DistributorOrderModel distributorOrderModel);
        Tuple<bool, string> UpdateOrderStatusById(List<int> ids, int orderStatusId);
    }


}
