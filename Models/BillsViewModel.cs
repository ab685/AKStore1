using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class BillsViewModel
    {
        public string BillHeading { get; set; }
        public string Title { get; set; }
        public string StoreName { get; set; }
        public string DeliveryAddress { get; set; }
        public DateTime BillDate { get; set; }
        public string Cashier { get; set; }
        public string DeliveryNote { get; set; }
        public decimal SubTotal { get; set; }
        public decimal Discount { get; set; }
        public decimal shippingAmount { get; set; }
        public decimal PreviousBalance { get; set; }
        public decimal BalanceToDate { get; set; }
        public decimal NetAmount { get; set; }
        public List<BillsItemModel> BillsItemModels { get; set; }

    }
    public class BillsItemModel
    {
        public string ProductName { get; set; }
        public decimal Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Amount { get; set; }
        public string StoreName { get; set; }
    }
}