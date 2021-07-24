using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class BillsViewModel
    {
        
        
        public string StoreName { get; set; }
        public string CustomerName { get; set; }
        public string Address { get; set; }
        public string PostalCode { get; set; }
        public DateTime BillDate { get; set; }
        public string DeliveryNote { get; set; }
        public decimal NetAmount { get; set; }
        public string DistributorName { get; set; }
        public List<BillsItemModel> BillsItemModels { get; set; }

    }
    public class BillsItemModel
    {
        public string CustomerName { get; set; }
        public string DistributorName { get; set; }
        public string Address { get; set; }
        public string ProductName { get; set; }
        public decimal Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Amount { get; set; }
        public string StoreName { get; set; }
        public string PostalCode { get; set; }
    }
}