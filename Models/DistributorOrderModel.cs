using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class DistributorOrderModel
    {
        public int DistributorId { get; set; }
        public int CustomerId { get; set; }
        public int OrderStatusId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
}