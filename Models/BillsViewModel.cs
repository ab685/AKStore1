using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class BillsViewModel
    {

        public int BillsId { get; set; }
        public string StoreName { get; set; }
        public string CustomerName { get; set; }
        public string Address { get; set; }
        public string PostalCode { get; set; }
        public DateTime BillDate { get; set; }
        public int BillNo { get; set; }
        public decimal NetAmount { get; set; }
        public string DistributorName { get; set; }
        public List<BillsItemModel> BillsItemModels { get; set; }
        public int? CustomerId { get; set; }
        public int? DistributorId { get; set; }
        public string FileName { get; set; }
    }
    public class BillsItemModel
    {
        public int CustomerId { get; set; }
        public int BillNo { get; set; }
        public string CustomerName { get; set; }
        public string DistributorName { get; set; }
        public int DistributorId { get; set; }
        public string Address { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Amount { get; set; }
        public string StoreName { get; set; }
        public string PostalCode { get; set; }
    }
}