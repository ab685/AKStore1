using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using AKStore.Extension;

namespace AKStore.Services
{
    public class OrderService : BaseService, IOrderService
    {
        private readonly IOrderRepository _orderRepository;
        private readonly IProductRepository _productRepository;
        private readonly ICustomerRepository _customerRepository;
        public OrderService()
        {
            _orderRepository = new OrderRepository();
            _productRepository = new ProductRepository();
            _customerRepository = new CustomerRepository();
        }

        public IEnumerable<OrderModels> GetOrderData(int retailerId, DateTime? fromDate, DateTime? toDate)
        {
            return _orderRepository.GetOrderData(retailerId, fromDate, toDate);
        }
        public Tuple<bool, string> UpsertOrder(CustomerProductModel customerProductModel)
        {
            OrderModels orderModels = new OrderModels();
            orderModels.CustomerId = customerProductModel.CustomerId;
            orderModels.ProductId = customerProductModel.ProductId;
            orderModels.Quantity = customerProductModel.Quantity;
            orderModels.OrderDate = customerProductModel.OrderDate;
            orderModels.Price = _productRepository.GetProductById(customerProductModel.ProductId).Price;
            orderModels.Total = orderModels.Price * orderModels.Quantity;
            orderModels.DistributorId = _customerRepository.GetCustomerById(customerProductModel.CustomerId).DistributorId;
            orderModels.OrderStatusId = Convert.ToInt32(OrderStatus.Odered);
            orderModels.IsActive = true;
            var orderMaster = AutoMapper.Mapper.Map<OrderMaster>(orderModels);
            return _orderRepository.UpsertOrder(orderMaster);
        }
        public Tuple<bool, string> DeleteOrder(int orderId)
        {
            return _orderRepository.DeleteOrder(orderId);
        }
        public Dictionary<string, decimal?> ChangeCustomerDetails(int customerId, int shift)
        {
            return _orderRepository.ChangeCustomerDetails(customerId, shift);
        }

        public OrderModels GetOrderById(int id)
        {
            var orderMaster = _orderRepository.GetOrderById(id);
            return AutoMapper.Mapper.Map<OrderModels>(orderMaster);
        }

        public List<OrderModels> GetDailyOrdersData(int retailerId, int routeId, int shift, DateTime saleDate)
        {
            return _orderRepository.GetDailyOrdersData(retailerId, routeId, shift, saleDate);
        }

        public DataSet CustomerDetailsReport(DateTime fromDate, DateTime toDate, int customerId, int retailerId)
        {
            return _orderRepository.CustomerDetailsReport(fromDate, toDate, customerId, retailerId);
        }
        public Tuple<bool, string> UpdateOrderStatusById(List<int> ids, int orderStatusId)
        {
            var result = _orderRepository.UpdateOrderStatusById(ids, orderStatusId);
            string msg = string.Empty;
            bool status = false;
            if (result == 1)
            {
                status = true;
                if (orderStatusId == Convert.ToInt32(OrderStatus.Odered))
                {
                    msg = "Selected orders are changed to Ordered status";
                }
                else if (orderStatusId == Convert.ToInt32(OrderStatus.Confirmed))
                {
                    msg = "Selected orders are changed to Confirmed status";
                }
                else if (orderStatusId == Convert.ToInt32(OrderStatus.Delivered))
                {
                    msg = "Selected orders are changed to Delivered status";
                }
                else if (orderStatusId == Convert.ToInt32(OrderStatus.Canceled))
                {
                    msg = "Selected orders are changed to Canceled status";
                }
                else if (orderStatusId == Convert.ToInt32(OrderStatus.Deleted))
                {
                    msg = "Selected orders are deleted successfully";
                }
            }
            else
            {
                msg = "Some thing went wrong";
                status = false;
            }
            return new Tuple<bool, string>(status, msg);
        }

        public List<DistributorOrderDataModel> GetOrderDataForDistributor(DistributorOrderModel distributorOrderModel)
        {
            return _orderRepository.GetOrderDataForDistributor(distributorOrderModel);
        }
        public DistributorOrderDataModel GetOrderDataForDistributorById(int id)
        {
            return _orderRepository.GetOrderDataForDistributorByOrderId(id);
        }

        public Tuple<bool, string> UpsertOrderDistributor(DistributorOrderDataModel distributorOrderDataModel)
        {
            OrderModels orderModels = new OrderModels();
            orderModels.Id = distributorOrderDataModel.Id;
            orderModels.CustomerId = distributorOrderDataModel.CustomerId;
            orderModels.ProductId = distributorOrderDataModel.ProductId;
            orderModels.Quantity = distributorOrderDataModel.Quantity;
            orderModels.OrderDate = distributorOrderDataModel.OrderDate;
            orderModels.Price = distributorOrderDataModel.Price;
            orderModels.Total = orderModels.Price * orderModels.Quantity;
            orderModels.DistributorId = _customerRepository.GetCustomerById(distributorOrderDataModel.CustomerId).DistributorId;
            orderModels.OrderStatusId = Convert.ToInt32(distributorOrderDataModel.OrderStatusId);
            orderModels.IsActive = true;
            var orderMaster = AutoMapper.Mapper.Map<OrderMaster>(orderModels);
            return _orderRepository.UpsertOrder(orderMaster);
        }
        public List<BillsItemModel> GetOrderBillsData(List<int> orderIds)
        {
            return _orderRepository.GetOrderBillsData(orderIds);
        }

        public void InsertBillsData(BillsViewModel billsViewModel)
        {
            _orderRepository.InsertBillsData(billsViewModel);
        }
        public List<BillsViewModel> BillsHistoryData(DateTime fromDate, DateTime toDate, int customerId = 0)
        {
            return _orderRepository.BillsHistoryData(fromDate, toDate, customerId);
        }
        public BillsViewModel GetBillsHistoryPDF(int id)
        {
            return _orderRepository.GetBillsHistoryPDF(id);
        }
    }
}
