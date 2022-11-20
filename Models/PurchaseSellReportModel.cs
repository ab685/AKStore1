using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class PurchaseSellReportModel
    {
        public string ProductName { get; set; }
        public string Customer { get; set; }
        public int QuantityDeliverd { get; set; }
        public decimal TotalPurchasedPrice { get; set; }
        public decimal TotalSellPrice { get; set; }
        public decimal Profit { get; set; }
    }
}