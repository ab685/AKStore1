using AKStore.Entity;
using AKStore.Models;
using System;
using System.Collections.Generic;
using System.Data;

namespace AKStore.Repository
{
    public interface IOrderRepository : IBaseRepository<OrderMaster>
    {
        IEnumerable<OrderModels> GetOrderData(int retailerId, DateTime? fromDate, DateTime? toDate);

        Tuple<bool, string> UpsertOrder(OrderMaster orderMaster);
        Tuple<bool, string> DeleteOrder(int orderId);
        Dictionary<string, decimal?> ChangeCustomerDetails(int customerId, int shift);
        List<OrderModels> GetDailyOrdersData(int retailerId, int routeId, int shift, DateTime saleDate);
        DataSet CustomerDetailsReport(DateTime fromDate, DateTime toDate, int customerId, int retailerId);
        OrderMaster GetOrderById(int id);
        int UpdateOrderStatusById(List<int> ids, int orderStatusId);
        List<DistributorOrderDataModel> GetOrderDataForDistributor(DistributorOrderModel distributorOrderModel);
        DistributorOrderDataModel GetOrderDataForDistributorByOrderId(int id);
        List<BillsItemModel> GetOrderBillsData(List<int> orderIds);
        void InsertBillsData(BillsViewModel billsViewModel);
        List<BillsViewModel> BillsHistoryData(DateTime fromDate, DateTime toDate, int customerId = 0);
        BillsViewModel GetBillsHistoryPDF(int id);
        List<PurchaseSellReportModel> PurchaseSellReport(int customerId, int productId,DateTime? fromDate, DateTime? toDate);
    }

}
