using System;
using System.Web.Mvc;

namespace AKStore.Models
{
    public class DistributorOrderDataModel
    {
        public int Id { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
        public decimal Total { get; set; }
        public int DistributorId { get; set; }
        public int CustomerId { get; set; }
        public int OrderStatusId { get; set; }
        public DateTime? OrderDate { get; set; }
        public string ProductName { get; set; }
        public int ProductId { get; set; }
        public string FilePath { get; set; }
        public string StoreName { get; set; }
        public SelectList Products { get; set; }
    }
}